//===--- Build.swift -----------------------------------------------------------===//
//Copyright (c) 2015-2016 Daniel Leping (dileping)
//
//This file is part of Swift Express Command Line
//
//Swift Express Command Line is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//Swift Express Command Line is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with Swift Express Command Line. If not, see <http://www.gnu.org/licenses/>.
//
//===---------------------------------------------------------------------------===//

import Commandant
import Result
import Regex
import Foundation

enum BuildType : Equatable, CustomStringConvertible {
    case Debug
    case Release
    
    var description: String {
        switch self {
        case .Debug:
            return "Debug"
        case .Release:
            return "Release"
        }
    }
    
    var spmValue: String {
        switch self {
        case .Debug:
            return "debug"
        case .Release:
            return "release"
        }
    }
}

func ==(lhs: BuildType, rhs: BuildType) -> Bool {
    switch (lhs, rhs) {
    case (.Debug, .Debug), (.Release, .Release):
        return true
    default:
        return false
    }
}

struct BuildStep:Step {
    let dependsOn:[Step] = [FindXcodeProject(), CarthageInstallLibs(updateCommand: "bootstrap", force: false)]
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let path = params["path"] as? String else {
            throw SwiftExpressError.BadOptions(message: "Build: No path option.")
        }
        guard let buildType = params["buildType"] as? BuildType else {
            throw SwiftExpressError.BadOptions(message: "Build: No buildType option.")
        }
        guard let force = params["force"] as? Bool else {
            throw SwiftExpressError.BadOptions(message: "Build: No force option.")
        }
        guard let name = combinedOutput["projectName"] as? String else {
            throw SwiftExpressError.BadOptions(message: "Build: Can't find Xcode project in working folder.")
        }
        guard let file = combinedOutput["projectFileName"] as? String else {
            throw SwiftExpressError.BadOptions(message: "Build: Can't find Xcode project in working folder.")
        }
        
        print("Building \(name) in \(buildType.description) mode...")
        
        if force {
            let appdir = path.addPathComponent("dist").addPathComponent(buildType.description)
            if FileManager.isDirectoryExists(appdir) {
                try FileManager.removeItem(appdir)
            }
            let objdir = path.addPathComponent("dist").addPathComponent(name+".build").addPathComponent(buildType.description)
            if FileManager.isDirectoryExists(objdir) {
                try FileManager.removeItem(objdir)
            }
        }
        
        let result = try SubTask(task: "/usr/bin/env", arguments: ["xcodebuild", "-project", file, "-scheme", name, "-configuration", buildType.description, "build"], workingDirectory: path, environment: nil, useAppOutput: true).runAndWait()
        if result != 0 {
            throw SwiftExpressError.SubtaskError(message: "Build task failed. Exit code \(result)")
        }
        return [String: Any]()
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
    }
    
    func revert(params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        switch error {
        case .SubtaskError(_)?:
            if let path = params["path"] as? String {
                let buildDir = path.addPathComponent("dist")
                if FileManager.isDirectoryExists(buildDir) {
                    let hiddenRe = "^\\.[^\\.]+".r!
                    do {
                        let builds = try FileManager.listDirectory(buildDir)
                        for build in builds {
                            if hiddenRe.matches(build) {
                                continue
                            }
                            try FileManager.removeItem(buildDir.addPathComponent(build))
                        }
                    } catch {}
                }
            }
        default:
            return
        }
    }
    
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        if ownParams["path"] == nil {
            throw SwiftExpressError.BadOptions(message: "Build: No path option.")
        }
        return ["workingFolder": ownParams["path"]!]
    }
}

extension BuildType:ArgumentType {
    static let name = "build-type"
    static func fromString(string: String) -> BuildType? {
        switch string {
        case "debug":
            return .Debug
        case "release":
            return .Release
        default:
            return nil
        }
    }
}

struct BuildCommand : StepCommand {
    typealias Options = BuildCommandOptions
    
    let verb = "build"
    let function = "build Express project"
    var step: Step = BuildStep()
    
    func step(opts: Options) -> Step {
        if opts.spm || !opts.xcode || IS_LINUX {
            return BuildSPMStep()
        }
        return BuildStep()
    }
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result([
                "buildType": opts.buildType,
                "path": opts.path.standardizedPath(),
                "force": opts.force,
                "dispatch": opts.dispatch
        ])
    }
}

struct BuildCommandOptions : OptionsType {
    let path: String
    let spm: Bool
    let xcode: Bool
    let force: Bool
    let dispatch: Bool
    let buildType: BuildType
    
    static func create(path: String) -> (Bool -> (Bool -> (Bool -> (Bool -> (BuildType -> BuildCommandOptions))))) {
        return { (spm: Bool) in 
            { (xcode: Bool) in 
                { (force: Bool) in
                    { (dispatch: Bool) in 
                        { (buildType: BuildType) in
                            BuildCommandOptions(path: path, spm: spm, xcode: xcode, force: force, dispatch: dispatch, buildType: buildType)
                        }
                    }
                }
            }
        }
    }
    
    static func evaluate(m: CommandMode) -> Result<BuildCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "spm", defaultValue: DEFAULTS_USE_SPM, usage: "use SPM as build tool")
            <*> m <| Option(key: "xcode", defaultValue: DEFAULTS_USE_XCODE, usage: "use Xcode as build tool")
            <*> m <| Option(key: "force", defaultValue: false, usage: "force build even if already compiled")
            <*> m <| Option(key: "dispatch", defaultValue: DEFAULTS_BUILD_DISPATCH, usage: "use Dispatch library. Always true on OS X")
            <*> m <| Argument(defaultValue: .Debug, usage: "build type. debug or release")
    }
}

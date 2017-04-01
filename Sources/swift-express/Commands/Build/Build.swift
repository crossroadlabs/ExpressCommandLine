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
    case debug
    case release
    
    var description: String {
        switch self {
        case .debug:
            return "debug"
        case .release:
            return "release"
        }
    }
}

func ==(lhs: BuildType, rhs: BuildType) -> Bool {
    switch (lhs, rhs) {
    case (.debug, .debug), (.release, .release):
        return true
    default:
        return false
    }
}

struct BuildStep : RunSubtaskStep {
    let dependsOn:[Step] = [Checkout(force: false)]
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let path = params["path"] as? URL else {
            throw SwiftExpressError.badOptions(message: "Build: No path option.")
        }
        guard let buildType = params["buildType"] as? BuildType else {
            throw SwiftExpressError.badOptions(message: "Build: No buildType option.")
        }
        guard let force = params["force"] as? Bool else {
            throw SwiftExpressError.badOptions(message: "Build: No force option.")
        }
        
        print("Building in \(buildType.description) mode with Swift Package Manager...")
        
        if force {
            let buildpath = path.appendingPathComponent(".build").appendingPathComponent(buildType.description)
            if FileManager.default.directoryExists(at: buildpath) {
                try FileManager.default.removeItem(at: buildpath)
            }
        }
        
        let args = ["swift", "build", "-c", buildType.description]
        
        let result = try executeSubtaskAndWait(Process(task: "/usr/bin/env", arguments: args, workingDirectory: path, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.subtaskError(message: "Build task exited with status \(result)")
        }
        return [String: Any]()
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
    }
    
    func revert(_ params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        switch error {
        case .subtaskError(_)?:
            if let path = params["path"] as? URL {
                let buildDir = path.appendingPathComponent(".build")
                if FileManager.default.directoryExists(at: buildDir) {
                    let hiddenRe = "^\\.[^\\.]+".r!
                    do {
                        let builds = try FileManager.default.contentsOfDirectory(at: buildDir, includingPropertiesForKeys: nil)
                        for build in builds {
                            if hiddenRe.matches(build.path) {
                                continue
                            }
                            try FileManager.default.removeItem(at: build)
                        }
                    } catch {}
                }
            }
        default:
            return
        }
    }
    
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        guard ownParams["path"] != nil else {
            throw SwiftExpressError.badOptions(message: "Build: No path option.")
        }
        return ["workingFolder": ownParams["path"]!]
    }
}

extension BuildType : ArgumentProtocol {
    static let name = "build-type"
    static func from(string: String) -> BuildType? {
        switch string {
        case "debug":
            return .debug
        case "release":
            return .release
        default:
            return nil
        }
    }
}

struct BuildCommand : SimpleStepCommand {
    typealias Options = BuildCommandOptions
    
    let verb = "build"
    let function = "build Express project"
    let step: Step = BuildStep()
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result([
                "buildType": opts.buildType,
                "path": opts.path.standardized,
                "force": opts.force,
        ])
    }
}

struct BuildCommandOptions : OptionsProtocol {
    let path: URL
    let force: Bool
    let buildType: BuildType
    
    static func create(_ path: String) -> ((Bool) -> ((BuildType) -> BuildCommandOptions)) {
        return { force in { buildType in BuildCommandOptions(path: URL(fileURLWithPath: path), force: force, buildType: buildType) } }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<BuildCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "force", defaultValue: false, usage: "force build even if already compiled")
            <*> m <| Argument(defaultValue: .debug, usage: "build type. debug or release")
    }
}

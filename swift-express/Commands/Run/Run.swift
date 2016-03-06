//===--- Run.swift -----------------------------------------------------------===//
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
import Foundation


struct RunStep : Step {
    let dependsOn:[Step] = [FindXcodeProject()]
    
    static var task: SubTask? = nil
    
    private func registerSignals(task: SubTask) {
        RunStep.task = task
        trap_signal(.INT, action: { signal -> Void in
            if RunStep.task != nil {
                RunStep.task!.interrupt()
                RunStep.task = nil
            }
        })
        trap_signal(.TERM, action: { signal -> Void in
            if RunStep.task != nil {
                RunStep.task!.terminate()
                RunStep.task = nil
            }
        })
    }
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let path = params["path"] as? String else {
            throw SwiftExpressError.BadOptions(message: "Run: No path option.")
        }
        guard let buildType = params["buildType"] as? BuildType else {
            throw SwiftExpressError.BadOptions(message: "Run: No buildType option.")
        }
        guard let name = combinedOutput["projectName"] as? String else {
            throw SwiftExpressError.BadOptions(message: "Run: Can't find Xcode project.")
        }
        
        print ("Running \(name)...")
        
        let binaryPath = path.addPathComponent("dist").addPathComponent(buildType.description).addPathComponent("\(name).app").addPathComponent("Contents").addPathComponent("MacOS").addPathComponent(name)

        let task = SubTask(task: binaryPath, arguments: nil, workingDirectory: path, environment: nil, useAppOutput: true)
        
        defer {
            RunStep.task = nil
        }
        
        registerSignals(task)
        
        try task.runAndWait()
        
        return [String:Any]()
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
        
    }
    
    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        return ["workingFolder": ownParams["path"]!]
    }
    
//    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
//        return ownParams ++ ["force": false]
//    }
}

struct RunCommandOptions : OptionsType {
    let path: String
    let spm: Bool
    let xcode: Bool
    let buildType: BuildType
    
    static func create(path: String) -> (Bool -> (Bool -> (BuildType -> RunCommandOptions))) {
        return { (spm: Bool) in
            { (xcode: Bool) in
                { (buildType: BuildType) in 
                    RunCommandOptions(path: path, spm: spm, xcode: xcode, buildType: buildType)
                }
            }
        }
    }
    
    static func evaluate(m: CommandMode) -> Result<RunCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "spm", defaultValue: DEFAULTS_USE_SPM, usage: "use SPM as build tool")
            <*> m <| Option(key: "xcode", defaultValue: DEFAULTS_USE_XCODE, usage: "use Xcode as build tool")
            <*> m <| Argument(defaultValue: .Debug, usage: "build type. debug or release")
    }
}

struct RunCommand : StepCommand {
    typealias Options = RunCommandOptions
    
    let verb = "run"
    let function = "run Express project"
    
    func step(opts: Options) -> Step {
        if opts.spm || !opts.xcode || IS_LINUX {
            return RunSPMStep()
        }
        return RunStep()
    }
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["buildType": opts.buildType, "path": opts.path.standardizedPath()])
    }
}

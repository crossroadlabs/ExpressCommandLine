//===--- Run.swift ----------------------------------------------------------===//
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

import Foundation
import Result
import Commandant

infix operator ++

func ++ <K,V> (left: Dictionary<K,V>, right: Dictionary<K,V>?) -> Dictionary<K,V> {
    guard let right = right else { return left }
    return left.reduce(right) {
        var new = $0 as [K:V]
        new.updateValue($1.1, forKey: $1.0)
        return new
    }
}

struct RunStep : RunSubtaskStep {
    let dependsOn:[Step] = []
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let path = params["path"] as? URL else {
            throw SwiftExpressError.badOptions(message: "Run: No path option.")
        }
        guard let buildType = params["buildType"] as? BuildType else {
            throw SwiftExpressError.badOptions(message: "Run: No buildType option.")
        }
        
        print ("Running app...")
        
        let binaryPath = path.appendingPathComponent(".build").appendingPathComponent(buildType.description).appendingPathComponent("app")
        
        let result = try executeSubtaskAndWait(Process(task: binaryPath.path, workingDirectory: path, useAppOutput: true))
        
        if result != 0 {
            throw SwiftExpressError.subtaskError(message: "Run: App finished with non-zero code: \(result)")
        }
        
        return [String:Any]()
    }
    
    func cleanup(_ params: [String : Any], output: StepResponse) throws {
        
    }
    
//    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
//        return ownParams ++ ["force": false, "dispatch": DEFAULTS_BUILD_DISPATCH]
//    }
}

struct RunCommandOptions : OptionsProtocol {
    let path: URL
    let buildType: BuildType
    
    static func create(_ path: String) -> ((BuildType) -> RunCommandOptions) {
        return { (buildType: BuildType) in RunCommandOptions(path: URL(fileURLWithPath: path), buildType: buildType) }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<RunCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Argument(defaultValue: .debug, usage: "build type. debug or release")
    }
}

struct RunCommand : SimpleStepCommand {
    typealias Options = RunCommandOptions
    
    let verb = "run"
    let function = "run Express project"
    let step: Step = RunStep()
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["buildType": opts.buildType, "path": opts.path.standardized])
    }
}

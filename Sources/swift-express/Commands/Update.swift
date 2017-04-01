//===--- Update.swift ----------------------------------------------------------===//
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

import Result
import Commandant
import Foundation

// Install project dependencies.
//Input:
// workingFolder
//Output:
// None
struct Update : RunSubtaskStep {
    let dependsOn = [Step]()
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "Bootstrap: No workingFolder option.")
        }
        guard let force = params["force"] as? Bool else {
            throw SwiftExpressError.badOptions(message: "Bootstrap: No force option.")
        }
        
        if force {
            let result = try executeSubtaskAndWait(Process(task: "/usr/bin/env", arguments: ["swift", "package", "reset"], workingDirectory: workingFolder, useAppOutput: true))
            if result != 0 {
                throw SwiftExpressError.subtaskError(message: "Bootstrap: package reset failed. Exit code \(result)")
            }
        }
        
        let result = try executeSubtaskAndWait(Process(task: "/usr/bin/env", arguments: ["swift", "package", "update"], workingDirectory: workingFolder, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.subtaskError(message: "Bootstrap: package fetch failed. Exit code \(result)")
        }
        
        return [String:Any]()
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
    }
}


struct UpdateCommand : SimpleStepCommand {
    typealias Options = UpdateCommandOptions
    
    let verb = "update"
    let function = "update and build Express project dependencies"
    let step: Step = Update()
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardized, "force": opts.force])
    }
}

struct UpdateCommandOptions : OptionsProtocol {
    let path: URL
    let force: Bool
    
    static func create(_ path: String) -> ((Bool) -> UpdateCommandOptions){
        return { force in UpdateCommandOptions(path: URL(fileURLWithPath: path), force: force) }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<UpdateCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "force", defaultValue: false, usage: "force build even if already compiled")
    }
}

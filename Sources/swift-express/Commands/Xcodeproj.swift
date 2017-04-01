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
import Foundation


struct XcodeprojStep : RunSubtaskStep {
    let dependsOn = [Step]()
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "xcodeproj: No workingFolder option.")
        }
        
        let result = try executeSubtaskAndWait(Process(task: "/usr/bin/env", arguments: ["swift", "package", "generate-xcodeproj"], workingDirectory: workingFolder, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.subtaskError(message: "xcodeproj task exited with status \(result)")
        }
        return [String: Any]()
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
    }
}

struct XcodeprojCommand : SimpleStepCommand {
    typealias Options = XcodeprojCommandOptions
    
    let verb = "xcodeproj"
    let function = "generate Xcode project"
    let step: Step = XcodeprojStep()
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardized])
    }
}

struct XcodeprojCommandOptions : OptionsProtocol {
    let path: URL
    
    static func create(_ path: String) -> XcodeprojCommandOptions {
        return XcodeprojCommandOptions(path: URL(fileURLWithPath: path))
    }
    
    static func evaluate(_ m: CommandMode) -> Result<XcodeprojCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
    }
}

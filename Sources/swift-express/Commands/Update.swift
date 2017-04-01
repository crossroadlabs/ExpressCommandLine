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

struct RemoveAndUpdateStep: Step {
    var dependsOn: [Step]
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        return [String: Any]()
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
    }
    
    func callParams(_ ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        guard let path = ownParams["workingFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "UpdateSPM: No path option.")
        }
        return ["workingFolder": path]
    }
}

struct UpdateCommand : SimpleStepCommand {
    typealias Options = UpdateCommandOptions
    
    let verb = "update"
    let function = "update and build Express project dependencies"
    let step: Step = RemoveAndUpdateStep(dependsOn: [RemoveItemsStep(items: [".build"]), Checkout(force: true)])
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardized])
    }
}

struct UpdateCommandOptions : OptionsProtocol {
    let path: URL
    let fetch: Bool
    
    static func create(_ path: String) -> ((Bool) -> UpdateCommandOptions) {
        return { (fetch: Bool) in UpdateCommandOptions(path: URL(fileURLWithPath: path), fetch: fetch) }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<UpdateCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "fetch", defaultValue: false, usage: "only fetch. Always true for SPM")
    }
}

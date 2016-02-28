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

struct RemoveAndUpdateStep: Step {
    var dependsOn: [Step]
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        return [String: Any]()
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        if ownParams["path"] == nil {
            throw SwiftExpressError.BadOptions(message: "Build: No path option.")
        }
        return ["workingFolder": ownParams["path"]!]
    }
}

struct UpdateCommand : StepCommand {
    typealias Options = BootstrapCommandOptions
    
    let verb = "update"
    let function = "update and build Express project dependencies"
    
    func step(opts: Options) -> Step {
        if opts.spm || !opts.carthage {
            return RemoveAndUpdateStep(dependsOn: [RemoveItemsStep(items: ["Packages"]), CheckoutSPM(force: true)])
        }
        if opts.fetch {
            return RemoveAndUpdateStep(dependsOn: [RemoveItemsStep(items: ["Carthage", "Cartfile.resolved"]), CarthageInstallLibs(updateCommand: "checkout", force: true)])
        }
        return CarthageInstallLibs(updateCommand: "update", force: true)
    }
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardizedPath()])
    }
}
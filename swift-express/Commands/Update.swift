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
        guard let path = ownParams["path"] as! String? else {
            throw SwiftExpressError.BadOptions(message: "UpdateSPM: No path option.")
        }
        return ["workingFolder": path]
    }
}

struct UpdateCommand : StepCommand {
    typealias Options = UpdateCommandOptions
    
    let verb = "update"
    let function = "update and build Express project dependencies"
    
    func step(opts: Options) -> Step {
        if opts.spm || !opts.carthage {
            return RemoveAndUpdateStep(dependsOn: [RemoveItemsStep(items: ["Packages"]), CheckoutSPM(force: true)])
        }
        if opts.fetch {
            return CarthageInstallLibs(updateCommand: "update", force: true, fetchOnly: true)
        }
        return CarthageInstallLibs(updateCommand: "update", force: true, fetchOnly: false)
    }
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardizedPath()])
    }
}

struct UpdateCommandOptions : OptionsType {
    let path: String
    let spm: Bool
    let carthage: Bool
    let fetch: Bool
    
    static func create(path: String)(spm: Bool)(carthage: Bool)(fetch: Bool) -> UpdateCommandOptions {
        return UpdateCommandOptions(path: path, spm: spm, carthage: carthage, fetch: fetch)
    }
    
    static func evaluate(m: CommandMode) -> Result<UpdateCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "spm", defaultValue: false, usage: "use SPM as package manager")
            <*> m <| Option(key: "carthage", defaultValue: true, usage: "use Carthage as package manager")
            <*> m <| Option(key: "fetch", defaultValue: false, usage: "only fetch")
    }
}
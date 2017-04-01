//===--- Init.swift -------------------------------===//
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
//===---------------------------------------------===//

import Commandant
import Result
import Foundation

struct InitStep : Step {
    let dependsOn:[Step] = [CreateTempDirectory(), CloneGitRepository(),
        CopyDirectoryContents(excludeList: ["^\\.git$", "^LICENSE$", "^NOTICE$", "^README.md$"]), GetProjectNameStep(), RenamePackageSwift()]
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        // Nothing to do. All tasks done
        return [String: Any]()
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
        // Nothing to do
    }
    
    func callParams(_ ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        switch forStep {
        case _ as CloneGitRepository:
            return ["repositoryURL": ownParams["template"]!, "outputFolder": previousStepsOutput["tempDirectory"]!]
        case _ as CreateTempDirectory:
            return [String: Any]()
        case _ as CopyDirectoryContents:
            let path = (ownParams["path"]! as! URL).appendingPathComponent(ownParams["name"]! as! String)
            return ["inputFolder": previousStepsOutput["clonedFolder"]!, "outputFolder": path]
        case _ as GetProjectNameStep:
            return ["workingFolder": previousStepsOutput["outputFolder"]!]
        case _ as RenamePackageSwift:
            return ["workingFolder": previousStepsOutput["outputFolder"]!, "newProjectName": ownParams["name"]!, "projectName": previousStepsOutput["projectName"]!]
        default:
            throw SwiftExpressError.badOptions(message: "InitStep: Wrong subsstep")
        }
    }
}

struct InitCommand: SimpleStepCommand {
    typealias Options = InitCommandOptions
    
    let verb = "init"
    let function = "Creates new Express application project"
    let step: Step = InitStep()
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["name": opts.name, "template": opts.template, "path": opts.path.standardized])
    }
}

struct InitCommandOptions : OptionsProtocol {
    let name: String
    let template: String
    let path: URL
    
    static func create(template: String) -> ((String) -> ((String) -> InitCommandOptions)) {
        return { path in { name in InitCommandOptions(name: name, template: template, path: URL(fileURLWithPath: path)) } }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<InitCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "template", defaultValue: "https://github.com/crossroadlabs/ExpressTemplate.git", usage: "git url for project template")
            <*> m <| Option(key: "path", defaultValue: ".", usage: "output directory")
            <*> m <| Argument(usage: "name of application")
    }
}

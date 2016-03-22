//===--- CarthageInstallLibs.swift -------------------------------===//
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
//===-------------------------------------------------------------===//

import Foundation
import Regex

// Install carthage dependencies.
//Input:
// workingFolder
//Output:
// None
struct CarthageInstallLibs : RunSubtaskStep {
    let dependsOn = [Step]()
    
    let platform = "Mac"
    let updateCommand: String
    let force:Bool
    let fetchOnly: Bool
    
    init(updateCommand: String = "bootstrap", force: Bool = true, fetchOnly: Bool = false) {
        self.updateCommand = updateCommand
        self.force = force
        self.fetchOnly = fetchOnly
    }
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? String else {
            throw SwiftExpressError.BadOptions(message: "CarthageInstallLibs: No workingFolder option.")
        }
        
        if !force && FileManager.isDirectoryExists(workingFolder.addPathComponent("Carthage").addPathComponent("Build")) {
            //All ok. We already have build dependencies
            return [String:Any]()
        }
        
        
        var args = [updateCommand, "--platform", platform]
        if fetchOnly {
            args.insert("--no-build", atIndex: 1)
        }
        
        let result = try executeSubtaskAndWait(SubTask(task: "/usr/local/bin/carthage", arguments: args, workingDirectory: workingFolder, environment: nil, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.SubtaskError(message: "CarthageInstallLibs: bootstrap failed. Exit code \(result)")
        }
        return [String:Any]()
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
        let workingFolder = params["workingFolder"]! as! String
        let plRe = platform.r!
        let cartBuildFolder = workingFolder.addPathComponent("Carthage").addPathComponent("Build")
        do {
            let plfms = try FileManager.listDirectory(cartBuildFolder)
            for plf in plfms {
                if plRe.matches(plf) {
                    continue
                }
                try FileManager.removeItem(cartBuildFolder.addPathComponent(plf))
            }
        } catch {
            print("CarthageInstallLibs: Some error on cleanup \(error)")
        }
        
    }
    
    func revert(params:[String: Any], output: [String: Any]?, error: SwiftExpressError?) {
        if let workingFolder = params["workingFolder"] {
            do {
                let cartPath = (workingFolder as! String).addPathComponent("Carthage")
                if FileManager.isDirectoryExists(cartPath) {
                    try FileManager.removeItem(cartPath)
                }
            } catch {
                print("Can't revert CarthageInstallLibs: \(error)")
            }
        }
    }
}
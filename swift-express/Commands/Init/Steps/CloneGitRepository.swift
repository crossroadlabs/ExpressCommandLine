//===--- CloneGitRepository.swift -------------------------------------===//
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
//===------------------------------------------------------------------===//

import Foundation

// Clones repository to folder.
// Input: repositoryURL : String
// Input: outputFolder : String
// Output: clonedFolder: String
struct CloneGitRepository : RunSubtaskStep {
    let dependsOn = [Step]()
    
    let folderExistsMessage = "CloneGitRepository: Output Folder already exists"
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let repositoryURL = params["repositoryURL"] as? String else {
            throw SwiftExpressError.BadOptions(message: "CloneGitRepository: No repositoryURL option.")
        }
        guard let outputFolder = params["outputFolder"] as? String else {
            throw SwiftExpressError.BadOptions(message: "CloneGitRepository: No outputFolder option.")
        }
        
        let result = try executeSubtaskAndWait(SubTask(task: "/usr/bin/env", arguments: ["git", "clone", repositoryURL, outputFolder], workingDirectory: nil, environment: nil, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.SubtaskError(message: "git clone failed")
        }
        
        return ["clonedFolder": outputFolder]
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
    }
    
    func revert(params:[String: Any], output: [String: Any]?, error: SwiftExpressError?) {
        switch error {
        case .BadOptions(let message)?:
            if message == folderExistsMessage {
                return
            }
            fallthrough
        default:
            if let outputFolder = params["outputFolder"] as? String {
                if FileManager.isDirectoryExists(outputFolder) {
                    do {
                        try FileManager.removeItem(outputFolder)
                    } catch {
                        print("CloneGitRepository: Can't remove output folder on revert. \(error)")
                    }
                }
            }
        }
    }
}
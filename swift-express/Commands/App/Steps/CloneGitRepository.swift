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
struct CloneGitRepository : Step {
    let dependsOn = [Step]()
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        print("Params: \(params)")
        
        if params["repositoryURL"] == nil {
            throw SwiftExpressError.BadOptions(message: "CloneGitRepository: No repositoryURL option.")
        }
        
        if params["outputFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "CloneGitRepository: No outputFolder option.")
        }
        
        let repositoryURL = params["repositoryURL"]! as! String
        let outputFolder = params["outputFolder"]! as! String
        
        print("Output folder url \(outputFolder)")
        
        try Git.cloneGitRepository(repositoryURL, toPath: outputFolder)
        
        return ["clonedFolder": outputFolder]
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in CloneGitRepository?")
    }
    
}
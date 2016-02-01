//
//  CloneGitRepository.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/28/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

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
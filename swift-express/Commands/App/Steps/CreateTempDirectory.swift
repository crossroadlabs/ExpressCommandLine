//
//  CreateTempDirectory.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/28/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation

// Will create temp directory and put it inside "tempDirectory" option
struct CreateTempDirectory : Step {
    
    let dependsOn = [Step]()
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        let tempDir = FileManager.temporaryDirectory().addPathComponent("swift-express-\(UInt32.random(100000, upper: 999999))")
        
        do {
            try FileManager.createDirectory(tempDir, createIntermediate: true)
        } catch let err as NSError {
            throw SwiftExpressError.SomeNSError(error: err)
        }
        return ["tempDirectory": tempDir]
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
        if let tempDir = output["tempDirectory"] as! String? {
            do {
                try FileManager.removeItem(tempDir)
            } catch let err as NSError {
                throw SwiftExpressError.SomeNSError(error: err)
            }
        } else {
            throw SwiftExpressError.BadOptions(message:"No tempDirectory option")
        }
    }
    
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in CreateTempDirectory?")
    }
}
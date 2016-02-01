//
//  CarthageInstallLibs.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/1/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation

// Install carthage dependencies.
//Input:
// workingFolder
//Output:
// None
struct CarthageInstallLibs : Step {
    let dependsOn = [Step]()
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        if params["workingFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "CarthageInstallLibs: No workingFolder option.")
        }
        let workingFolder = params["workingFolder"]! as! String
        
        let task = SubTask(task: "/usr/local/bin/carthage", arguments: ["bootstrap", "--platform", "Mac", workingFolder], environment: nil, readCallback: nil, finishCallback: nil)
        if task.runAndWait() != 0 {
            let message = try task.readData().toString()
            print("Carthage error: \(message)")
            throw SwiftExpressError.SubtaskError(message: message)
        }
        return [String:Any]()
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in CarthageInstallLibs?")
    }
}
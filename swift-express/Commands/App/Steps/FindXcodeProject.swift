//
//  FindXcodeProject.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/1/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation
import Regex

// Find Xcode project in directory
// Input: workingFolder
// Output:
//      projectName: String - name of project
//      projectFileName: String - full name of xcodeproj directory
struct FindXcodeProject : Step {
    let dependsOn = [Step]()
    let xcprojR = "(.+)\\.xcodeproj".r!
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        if params["workingFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "FindXcodeProject: No workingFolder option.")
        }
        let workingFolder = params["workingFolder"]! as! String
        let contents = try FileManager.listDirectory(workingFolder)
        var result: String? = nil
        var name: String? = nil
        for item in contents {
            if let match = xcprojR.findFirst(item) {
                result = match.group(0)
                name = match.group(1)
            }
        }
        if result == nil || name == nil {
            throw SwiftExpressError.SubtaskError(message: "FindXcodeProject: Can't find any Xcode project in directory")
        }
        return ["projectName": name!, "projectFileName": result]
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in FindXcodeProject?")
    }
}
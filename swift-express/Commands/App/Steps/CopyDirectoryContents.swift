//
//  CopyDirectoryContents.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/1/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation
import Regex

//Copy contents of directory into another. Ignoring .git folder
//Input: inputFolder
//Input: outputFolder
//Output: 
//  copiedItems: Array<String>
//  outputFolder: String
struct CopyDirectoryContents : Step {
    let dependsOn = [Step]()
    let gitR = "\\.git$".r!
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        if params["inputFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "CopyDirectoryContents: No inputFolder option.")
        }
        
        if params["outputFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "CopyDirectoryContents: No outputFolder option.")
        }
        do {
            let inputFolder = params["inputFolder"]! as! String
            let outputFolder = params["outputFolder"]! as! String
        
            print("Output folder: \(outputFolder)")
            
            do {
                try FileManager.listDirectory(outputFolder)
            } catch {
                try FileManager.createDirectory(outputFolder, createIntermediate: true)
            }
        
            var copiedItems = [String]()
        
            let contents = try FileManager.listDirectory(inputFolder)
            print("Contents: \(contents)")
            for item in contents {
                if gitR.matches(item) {
                    continue
                }
                try FileManager.copyItem(inputFolder.addPathComponent(item), toDirectory: outputFolder)
                copiedItems.append(item)
                print("Copied: \(item)")
            }
            return ["copiedItems": copiedItems, "outputFolder": outputFolder]
        } catch let err as NSError {
            throw SwiftExpressError.SomeNSError(error: err)
        }
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in CopyDirectoryContents?")
    }
}
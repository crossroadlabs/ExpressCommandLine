//===--- CreateTempDirectory.swift -------------------------------------===//
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
//===-------------------------------------------------------------------===//

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
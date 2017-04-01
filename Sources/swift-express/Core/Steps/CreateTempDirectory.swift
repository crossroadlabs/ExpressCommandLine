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

    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        let tempDir = FileManager.default.tempDirectory.appendingPathComponent("swift-express-\(random(max: 999999, min: 100000))")
        
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        } catch let err as NSError {
            throw SwiftExpressError.someNSError(error: err)
        }
        return ["tempDirectory": tempDir]
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
        if let tempDir = output["tempDirectory"] as? URL {
            do {
                try FileManager.default.removeItem(at: tempDir)
            } catch let err as NSError {
                throw SwiftExpressError.someNSError(error: err)
            }
        } else {
            throw SwiftExpressError.badOptions(message:"No tempDirectory option")
        }
    }
    
    func revert(_ params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        if let output = output {
            if let dir = output["tempDirectory"] as? URL {
                if FileManager.default.directoryExists(at: dir) {
                    do {
                        try FileManager.default.removeItem(at: dir)
                    } catch {
                        print("CreateTempDirectory: Can't remove directory \(error)")
                    }
                }
                
            }
        }
    }
}

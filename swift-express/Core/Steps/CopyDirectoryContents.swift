//===--- CopyDirectoryContents.swift ----------------------------------===//
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
import Regex

//Copy contents of directory into another. Ignoring .git folder
//Input: inputFolder
//Input: outputFolder
//Output: 
//  copiedItems: Array<String>
//  outputFolder: String
struct CopyDirectoryContents : Step {
    let dependsOn = [Step]()
    let excludeList:[Regex]
    
    let alreadyExistsError = "CopyDirectoryContents: Output folder already exists."
    
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
            
            if FileManager.isDirectoryExists(outputFolder) || FileManager.isFileExists(outputFolder) {
                throw SwiftExpressError.BadOptions(message: alreadyExistsError)
            } else {
                try FileManager.createDirectory(outputFolder, createIntermediate: true)
            }
        
            var copiedItems = [String]()
        
            let contents = try FileManager.listDirectory(inputFolder)
            
            for item in contents {
                let ignore = excludeList.reduce(false, combine: { (prev, r) -> Bool in
                    return prev || r.matches(item)
                })
                if ignore {
                    continue
                }
                try FileManager.copyItem(inputFolder.addPathComponent(item), toDirectory: outputFolder)
                copiedItems.append(item)
            }
            return ["copiedItems": copiedItems, "outputFolder": outputFolder]
        } catch let err as SwiftExpressError {
            throw err
        } catch let err as NSError {
            throw SwiftExpressError.SomeNSError(error: err)
        } catch {
            throw SwiftExpressError.UnknownError(error: error)
        }
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
    
    func revert(params: [String : Any]?, output: [String : Any]?, error: SwiftExpressError?) {
        switch error {
        case .BadOptions(let message)?:
            if message == alreadyExistsError {
                return
            }
            fallthrough
        default:
            if let outputFolder = params?["outputFolder"] as? String {
                do {
                    try FileManager.removeItem(outputFolder)
                } catch {
                    print("CopyDirectoryContents: Can't remove output folder on revert \(outputFolder)")
                }
            }
        }
    }
    
    init(excludeList: [String]? = nil) {
        if excludeList != nil {
            self.excludeList = excludeList!.map({ str -> Regex in
                return str.r!
            })
        } else {
            self.excludeList = ["\\.git$".r!]
        }
    }
}
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
//  copiedItems: Array<URL>
//  outputFolder: URL
struct CopyDirectoryContents : Step {
    let dependsOn = [Step]()
    let excludeList: [Regex]
    
    let alreadyExistsError = "CopyDirectoryContents: Output folder already exists."
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let inputFolder = params["inputFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "CopyDirectoryContents: No inputFolder option.")
        }
        guard let outputFolder = params["outputFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "CopyDirectoryContents: No outputFolder option.")
        }

        do {
            if FileManager.default.directoryExists(at: outputFolder) || FileManager.default.fileExists(at: outputFolder) {
                throw SwiftExpressError.badOptions(message: alreadyExistsError)
            } else {
                try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
            }
        
            var copiedItems = [URL]()
        
            let contents = try FileManager.default.contentsOfDirectory(at: inputFolder, includingPropertiesForKeys: nil)
            
            for item in contents {
                let ignore = excludeList.reduce(false) { (prev, r) -> Bool in
                    return prev || r.matches(item.absoluteString)
                }
                if ignore {
                    continue
                }
                try FileManager.default.copyItem(at: item, to: outputFolder)
                copiedItems.append(item)
            }
            return ["copiedItems": copiedItems, "outputFolder": outputFolder]
        } catch let err as SwiftExpressError {
            throw err
        } catch let err as NSError {
            throw SwiftExpressError.someNSError(error: err)
        } catch {
            throw SwiftExpressError.unknownError(error: error)
        }
    }
    
    func cleanup(_ params: [String : Any], output: StepResponse) throws {
    }
    
    func revert(_ params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        switch error {
        case .badOptions(let message)?:
            if message == alreadyExistsError {
                return
            }
            fallthrough
        default:
            if let outputFolder = params["outputFolder"] as? URL {
                do {
                    try FileManager.default.removeItem(at: outputFolder)
                } catch {
                    print("CopyDirectoryContents: Can't remove output folder on revert \(outputFolder)")
                }
            }
        }
    }
    
    init(excludeList: [String]? = nil) {
        if let list = excludeList {
            self.excludeList = list.map {$0.r!}
        } else {
            self.excludeList = ["\\.git$".r!]
        }
    }
}

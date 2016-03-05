//===--- RemoveItemsStep.swift --------------------------------------------------===//
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
//===---------------------------------------------------------------------------===//

import Foundation

// Input: 
// Required: workingFolder
// Optional: items - [String]


struct RemoveItemsStep : Step {
    
    let dependsOn = [Step]()
    let items: [String]?
    
    init(items: [String]? = nil) {
        self.items = items
    }
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? String else {
            throw SwiftExpressError.BadOptions(message: "RemoveItems: No workingFolder option.")
        }
        
        var removeItems = [String]()
        if let i = self.items {
            removeItems.appendContentsOf(i)
        }
        if let i = params["items"] as! [String]? {
            removeItems.appendContentsOf(i)
        }
        
        for item in removeItems {
            let path = workingFolder.addPathComponent(item)
            do {
                if FileManager.isDirectoryExists(path) || FileManager.isFileExists(path) {
                    try FileManager.removeItem(path)
                }
            } catch let err as NSError {
                throw SwiftExpressError.SomeNSError(error: err)
            }
        }
        return [String: Any]()
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
    }
}
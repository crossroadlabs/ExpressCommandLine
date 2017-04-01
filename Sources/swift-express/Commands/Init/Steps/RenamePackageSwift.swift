//===--- RenamePackageSwift.swift --------------------------------===//
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
//===-------------------------------------------------------------===//

import Foundation
import Regex

//Rename Xcode project and it's target.
//Input:
//  workingFolder
//  projectName
//  newProjectName
struct RenamePackageSwift : Step {
    let dependsOn:[Step] = []
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "RenamePackageSwift: No workingFolder option.")
        }
        guard let projectName = params["projectName"] as? String else {
            throw SwiftExpressError.badOptions(message: "RenamePackageSwift: No projectName option.")
        }
        guard let newName = params["newProjectName"] as? String else {
            throw SwiftExpressError.badOptions(message: "RenamePackageSwift: No newProjectName option.")
        }
        
        let psFile = try FileHandle(forUpdating: workingFolder.appendingPathComponent("Package.swift"))
        
        let nameRegex = ("name:\\s*\"" + projectName + "\"").r!
        
        guard let fileContents = String(data: psFile.readDataToEndOfFile(), encoding: .utf8) else {
            throw SwiftExpressError.badOptions(message: "RenamePackageSwift: Empty Package.swift")
        }
        
        let newFileData = nameRegex.replaceAll(in: fileContents, with: "name: \"\(newName)\"")
        
        psFile.seek(toFileOffset: 0)
        psFile.truncateFile(atOffset: 0)
        
        if let data = newFileData.data(using: .utf8) {
            psFile.write(data)
        } else {
            throw SwiftExpressError.badOptions(message: "RenamePackageSwift: Can't generate data for Package.swit")
        }
        
        return [String:Any]()
    }
    
    func cleanup(_ params: [String : Any], output: StepResponse) throws {
    }
}

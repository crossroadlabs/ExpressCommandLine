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
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        if params["workingFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "RenamePackageSwift: No workingFolder option.")
        }
        let workingFolder = params["workingFolder"]! as! String
        
        if params["projectName"] == nil {
            throw SwiftExpressError.BadOptions(message: "RenamePackageSwift: No projectName option.")
        }
        let projectName = params["projectName"]! as! String
        
        if params["newProjectName"] == nil {
            throw SwiftExpressError.BadOptions(message: "RenamePackageSwift: No newProjectName option.")
        }
        let newName = params["newProjectName"]! as! String
        
        guard let pbFile = try? File(path: workingFolder.addPathComponent("Package.swift"), mode: .Append) else {
            return [String:Any]()
        }
        
        let nameRegex = ("name:\\s*\"" + projectName + "\"").r!
        let fileContents = try pbFile.readToEnd().toString()
        let newFileData = nameRegex.replaceAll(fileContents, replacement: "name: \"\(newName)\"")
        
        pbFile.seek(0)
        pbFile.resize(0)
        try pbFile.write(newFileData.toArray())
        
        return [String:Any]()
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
}

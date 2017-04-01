//===--- GetProjectName.swift --------------------------------------------------===//
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
import Regex

// Input:
//  Required: workingFolder
// Output:
//  projectName: String
struct GetProjectNameStep : Step {
    let dependsOn = [Step]()
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "GetProjectName: No workingFolder option.")
        }
        
        let psFile = try FileHandle(forReadingFrom: workingFolder.appendingPathComponent("Package.swift"))
        
        defer {
            psFile.closeFile()
        }
        
        let nameRegex = ("name:\\s*\"(\\w+)\"").r!
        
        guard let fileContents = String(data: psFile.readDataToEndOfFile(), encoding: .utf8) else {
            throw SwiftExpressError.badOptions(message: "GetProjectName: Empty Package.swift")
        }
        
        let name = nameRegex.findFirst(in: fileContents)
        
        guard let projectName = name?.group(at: 1) else {
            throw SwiftExpressError.badOptions(message: "GetProjectName: Name not found in Package.swift")
        }
        
        return ["projectName": projectName]
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
    }

}

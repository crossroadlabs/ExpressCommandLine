//===--- FindXcodeProject.swift ----------------------------------===//
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
        print("\(workingFolder)")
        do {
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
            return ["projectName": name!, "projectFileName": result!]
        } catch let err as NSError {
            throw SwiftExpressError.SomeNSError(error: err)
        }
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in FindXcodeProject?")
    }
}
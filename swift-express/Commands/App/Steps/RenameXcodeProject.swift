//
//  RenameXcodeProject.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/1/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation
import Regex

//Rename Xcode project and it's target.
//Input:
//  workingFolder
//  projectName
//  newProjectName
//Output:
//  projectPath - full path to new project
struct RenameXcodeProject : Step {
    let dependsOn = [Step]()
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        if params["workingFolder"] == nil {
            throw SwiftExpressError.BadOptions(message: "RenameXcodeProject: No workingFolder option.")
        }
        let workingFolder = params["workingFolder"]! as! String
        
        if params["projectName"] == nil {
            throw SwiftExpressError.BadOptions(message: "RenameXcodeProject: No projectName option.")
        }
        let projectName = params["projectName"]! as! String
        
        if params["newProjectName"] == nil {
            throw SwiftExpressError.BadOptions(message: "RenameXcodeProject: No newProjectName option.")
        }
        let newName = params["newProjectName"]! as! String
        let newProj = newName + ".xcodeproj"
        
        try FileManager.renameItem(workingFolder.addPathComponent(projectName+".xcodeproj"), newName: newProj)
        
        let pbProjName = newProj.addPathComponent("project.pbxproj")
        let pbFile = try File(path: workingFolder.addPathComponent(pbProjName), mode: .Append)
        
        let nameRegex = projectName.r!
        let fileContents = try pbFile.readToEnd().toString()
        let newFileData = nameRegex.replaceAll(fileContents, replacement: newName)

        pbFile.seek(0)
        pbFile.resize(0)
        try pbFile.write(newFileData.toArray())
        return [String:Any]()
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
    }
    
    func callParams(ownParams: [String : Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String : Any] {
        throw SwiftExpressError.SubtaskError(message: "Why callParams called in CarthageInstallLibs?")
    }
}
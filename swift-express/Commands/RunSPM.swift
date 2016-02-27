//===--- RunSPM.swift ----------------------------------------------------------===//
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
import Result

struct RunSPMStep : Step {
    let dependsOn:[Step] = [BuildSPMStep()]
    
    static var task: SubTask? = nil
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        if params["path"] == nil {
            throw SwiftExpressError.BadOptions(message: "Build: No path option.")
        }
        
        if params["buildType"] == nil {
            throw SwiftExpressError.BadOptions(message: "Build: No buildType option.")
        }
        
        let path = params["path"]! as! String
        let buildType = params["buildType"]! as! BuildType
        
        print ("Running app...")
        
        let binaryPath = path.addPathComponent(".build").addPathComponent(buildType.spmValue).addPathComponent("app")
        
        RunStep.task = SubTask(task: binaryPath, arguments: nil, workingDirectory: path, environment: nil, readCallback: { (task, data, isError) -> Bool in
            do {
                print(try data.toString(), terminator:"")
            } catch {}
            return true
            }, finishCallback: nil)
        
        trap_signal(.INT, action: { signal -> Void in
            if RunStep.task != nil {
                RunStep.task!.interrupt()
                RunStep.task = nil
            }
        })
        trap_signal(.TERM, action: { signal -> Void in
            if RunStep.task != nil {
                RunStep.task!.terminate()
                RunStep.task = nil
            }
        })
        
        try RunStep.task!.run()
        SubTask.waitForAllTaskTermination()
        
        return [String:Any]()
    }
    
    func cleanup(params: [String : Any], output: StepResponse) throws {
        
    }
}

struct RunSPMCommand : StepCommand {
    typealias Options = BuildCommandOptions
    
    let verb = "run-spm"
    let function = "run Express project with Swift Package Manager"
    let step: Step = RunSPMStep()
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["buildType": opts.buildType, "path": opts.path.standardizedPath()])
    }
}

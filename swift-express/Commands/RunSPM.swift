//
//  RunSPM.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/26/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

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

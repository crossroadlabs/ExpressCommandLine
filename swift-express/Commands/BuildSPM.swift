//
//  BuildSPM.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/26/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation
import Result

struct BuildSPMStep:Step {
    let dependsOn:[Step] = []
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        
        if params["path"] == nil {
            throw SwiftExpressError.BadOptions(message: "Build: No path option.")
        }
        
        if params["buildType"] == nil {
            throw SwiftExpressError.BadOptions(message: "Build: No buildType option.")
        }
        
        let path = params["path"]! as! String
        let buildType = params["buildType"]! as! BuildType
        
        print("Building in \(buildType.description) mode with Swift Package Manager...")
        
        var result : Int32 = 0
        var resultString:String = ""
        
        try SubTask(task: "/usr/bin/env", arguments: ["swift", "build", "-c", buildType.spmValue], workingDirectory: path, environment: nil, readCallback: { (task, data, isError) -> Bool in
            do {
                if isError {
                    resultString +=  try data.toString()
                }
            } catch {}
            return true
            }, finishCallback: { task, status in
                result = status
        }).run()
        SubTask.waitForAllTaskTermination()
        if result != 0 {
            throw SwiftExpressError.SubtaskError(message: resultString)
        }
        return [String: Any]()
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
    }
    
    func revert(params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        switch error {
        case .SubtaskError(_)?:
            if let path = params["path"] as? String {
                let buildDir = path.addPathComponent(".build")
                if FileManager.isDirectoryExists(buildDir) {
                    let hiddenRe = "^\\.[^\\.]+".r!
                    do {
                        let builds = try FileManager.listDirectory(buildDir)
                        for build in builds {
                            if hiddenRe.matches(build) {
                                continue
                            }
                            try FileManager.removeItem(buildDir.addPathComponent(build))
                        }
                    } catch {}
                }
            }
        default:
            return
        }
    }
}

struct BuildSPMCommand : StepCommand {
    typealias Options = BuildCommandOptions
    
    let verb = "build-spm"
    let function = "build Express project with Swift Package Manager"
    let step: Step = BuildSPMStep()
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["buildType": opts.buildType, "path": opts.path.standardizedPath()])
    }
}

//===--- BuildSPM.swift -------------------------------------------------------===//
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

struct BuildSPMStep : RunSubtaskStep {
    let dependsOn:[Step] = [CheckoutSPM(force: false)]
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let path = params["path"] as? String else {
            throw SwiftExpressError.BadOptions(message: "BuildSPM: No path option.")
        }
        guard let buildType = params["buildType"] as? BuildType else {
            throw SwiftExpressError.BadOptions(message: "BuildSPM: No buildType option.")
        }
        guard let force = params["force"] as? Bool else {
            throw SwiftExpressError.BadOptions(message: "BuildSPM: No force option.")
        }
        guard let dispatch = params["dispatch"] as? Bool else {
            throw SwiftExpressError.BadOptions(message: "BuildSPM: No dispatch option.")
        }
        
        print("Building in \(buildType.description) mode with Swift Package Manager...")
        
        if force {
            let buildpath = path.addPathComponent(".build").addPathComponent(buildType.spmValue)
            if FileManager.isDirectoryExists(buildpath) {
                try FileManager.removeItem(buildpath)
            }
        }
        var args = ["swift", "build", "-c", buildType.spmValue]
        if dispatch || !IS_LINUX {
            args.appendContentsOf(["-Xcc", "-fblocks", "-Xswiftc", "-Ddispatch"])
        }
        
        let result = try executeSubtaskAndWait(SubTask(task: "/usr/bin/env", arguments: args, workingDirectory: path, environment: nil, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.SubtaskError(message: "Build task exited with status \(result)")
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
    
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        if ownParams["path"] == nil {
            throw SwiftExpressError.BadOptions(message: "BuildSPM: No path option.")
        }
        return ["workingFolder": ownParams["path"]!]
    }
}

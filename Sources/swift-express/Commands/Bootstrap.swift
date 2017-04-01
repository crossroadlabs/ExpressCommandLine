//===--- Bootstrap.swift -------------------------------------------------------===//
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

import Result
import Commandant
import Foundation

// Install carthage dependencies.
//Input:
// workingFolder
//Output:
// None
struct Checkout : RunSubtaskStep {
    let dependsOn = [Step]()
    let force: Bool
    
    init(force: Bool = true) {
        self.force = force
    }
    
    func run(_ params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as? URL else {
            throw SwiftExpressError.badOptions(message: "Checkout: No workingFolder option.")
        }
        
        let pkgFolder = workingFolder.appendingPathComponent("Packages")
        
        if !force && FileManager.default.directoryExists(at: pkgFolder) {
            return [String:Any]()
        }
        
        let result = try executeSubtaskAndWait(Process(task: "/usr/bin/env", arguments: ["swift", "build", "--fetch"], workingDirectory: workingFolder, useAppOutput: true))
        if result != 0 {
            throw SwiftExpressError.subtaskError(message: "Checkout: package fetch failed. Exit code \(result)")
        }
        
        return [String:Any]()
    }
    
    func cleanup(_ params:[String: Any], output: StepResponse) throws {
    }
    
    func revert(params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        if let workingFolder = params["workingFolder"] {
            do {
                let pkgFolder = (workingFolder as! URL).appendingPathComponent("Packages")
                if FileManager.default.directoryExists(at: pkgFolder) {
                    try FileManager.default.removeItem(at: pkgFolder)
                }
            } catch {
                print("Checkout: Can't revert. \(error)")
            }
        }
    }
}

struct BootstrapCommand : SimpleStepCommand {
    typealias Options = BootstrapCommandOptions
    
    let verb = "bootstrap"
    let function = "download and build Express project dependencies"
    let step: Step = Checkout(force: true)
    
    func getOptions(_ opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardized])
    }
}

struct BootstrapCommandOptions : OptionsProtocol {
    let path: URL
    let fetch: Bool
    let noRefetch: Bool
    
    static func create(_ path: String) -> ((Bool) -> ((Bool) -> BootstrapCommandOptions)) {
        return  { fetch in { noRefetch in
            BootstrapCommandOptions(path: URL(fileURLWithPath: path), fetch: fetch, noRefetch: noRefetch)
        } } }
    
    static func evaluate(_ m: CommandMode) -> Result<BootstrapCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "fetch", defaultValue: false, usage: "only fetch. Always true for SPM (ignored if --no-refetch presents)")
            <*> m <| Option(key: "no-refetch", defaultValue: false, usage: "build without fetch. Always false for SPM.")
    }
}

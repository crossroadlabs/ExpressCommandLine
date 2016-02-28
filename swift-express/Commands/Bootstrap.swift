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

// Install carthage dependencies.
//Input:
// workingFolder
//Output:
// None
struct CheckoutSPM : Step {
    let dependsOn = [Step]()
    let force: Bool
    
    init(force: Bool = true) {
        self.force = force
    }
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any] {
        guard let workingFolder = params["workingFolder"] as! String? else {
            throw SwiftExpressError.BadOptions(message: "UpdateSPM: No workingFolder option.")
        }
        
        let pkgFolder = workingFolder.addPathComponent("Packages")
        
        if !force && FileManager.isDirectoryExists(pkgFolder) {
            return [String:Any]()
        }
        
        var result:Int32 = 0
        try SubTask(task: "/usr/bin/env", arguments: ["swift", "build", "--fetch"], workingDirectory: workingFolder, environment: nil, readCallback: { (task, data, isError) -> Bool in
            do {
                print(try data.toString(), terminator:"")
            } catch {}
            return true
            }, finishCallback: { task, status in
                result = status
        }).run()
        SubTask.waitForAllTaskTermination()
        if result != 0 {
            throw SwiftExpressError.SubtaskError(message: "UpdateSPM: package fetch failed")
        }
        
        return [String:Any]()
    }
    
    func cleanup(params:[String: Any], output: StepResponse) throws {
        guard let workingFolder = params["workingFolder"] as! String? else {
            throw SwiftExpressError.BadOptions(message: "UpdateSPM: No workingFolder option.")
        }
        let pkgFolder = workingFolder.addPathComponent("Packages")
        for pkg in try FileManager.listDirectory(pkgFolder) {
            let testsDir = pkgFolder.addPathComponent(pkg).addPathComponent("Tests")
            if FileManager.isDirectoryExists(testsDir) {
                try FileManager.removeItem(testsDir)
            }
        }
    }
    
    func revert(params: [String : Any], output: [String : Any]?, error: SwiftExpressError?) {
        if let workingFolder = params["workingFolder"] {
            do {
                let pkgFolder = (workingFolder as! String).addPathComponent("Packages")
                if FileManager.isDirectoryExists(pkgFolder) {
                    try FileManager.removeItem(pkgFolder)
                }
            } catch {
                print("Can't revert UpdateSPM: \(error)")
            }
        }
    }
}

struct BootstrapCommand : StepCommand {
    typealias Options = BootstrapCommandOptions
    
    let verb = "bootstrap"
    let function = "download and build Express project dependencies"
    
    func step(opts: Options) -> Step {
        if opts.spm || !opts.carthage {
            return CheckoutSPM(force: true)
        }
        if opts.fetch {
            return CarthageInstallLibs(updateCommand: "checkout", force: true)
        }
        return CarthageInstallLibs(updateCommand: "bootstrap", force: true)
    }
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardizedPath()])
    }
}

struct BootstrapCommandOptions : OptionsType {
    let path: String
    let spm: Bool
    let carthage: Bool
    let fetch: Bool
    
    static func create(path: String)(spm: Bool)(carthage: Bool)(fetch: Bool) -> BootstrapCommandOptions {
        return BootstrapCommandOptions(path: path, spm: spm, carthage: carthage, fetch: fetch)
    }
    
    static func evaluate(m: CommandMode) -> Result<BootstrapCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
            <*> m <| Option(key: "spm", defaultValue: false, usage: "use SPM as package manager")
            <*> m <| Option(key: "carthage", defaultValue: true, usage: "use Carthage as package manager")
            <*> m <| Option(key: "fetch", defaultValue: false, usage: "only fetch")
    }
}
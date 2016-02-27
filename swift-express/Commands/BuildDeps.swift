//===--- BuildDeps.swift ------------------------------------------------------===//
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

struct BuildDepsCommand : StepCommand {
    typealias Options = BuildDepsCommandOptions
    
    let verb = "build-deps"
    let function = "download and build Express project dependencies"
    let step: Step = CarthageInstallLibs(updateCommand: "update")
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError> {
        return Result(["workingFolder": opts.path.standardizedPath()])
    }
}

struct BuildDepsCommandOptions : OptionsType {
    let path: String
    
    static func create(path: String) -> BuildDepsCommandOptions {
        return BuildDepsCommandOptions(path: path)
    }
    
    static func evaluate(m: CommandMode) -> Result<BuildDepsCommandOptions, CommandantError<SwiftExpressError>> {
        return create
            <*> m <| Option(key: "path", defaultValue: ".", usage: "project directory")
    }
}

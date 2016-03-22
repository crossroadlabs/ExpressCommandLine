//===--- SwiftExpress.swift ---------------------------------------------------------===//
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
//===--------------------------------------------------------------------------------===//

import Commandant
import Foundation

let CMD_LINE_VERSION = "0.2.1"

#if os(Linux)
    let IS_LINUX = true
    
    let DEFAULTS_USE_SPM = true
    let DEFAULTS_USE_XCODE = false
    let DEFAULTS_BUILD_DISPATCH = false
#else
    let IS_LINUX = false
    
    let DEFAULTS_USE_SPM = false
    let DEFAULTS_USE_XCODE = true
    let DEFAULTS_BUILD_DISPATCH = true
#endif

let DEFAULTS_USE_CARTHAGE = DEFAULTS_USE_XCODE

enum SwiftExpressError : ErrorType {
    case SubtaskError(message: String)
    case SomeNSError(error: NSError)
    case BadOptions(message: String)
    case UnknownError(error: ErrorType)
}

func commandRegistry() -> CommandRegistry<SwiftExpressError> {
    let registry = CommandRegistry<SwiftExpressError>()
    
    //Commands
    registry.register(InitCommand())
    registry.register(BootstrapCommand())
    registry.register(UpdateCommand())
    registry.register(BuildCommand())
    registry.register(RunCommand())
    registry.register(VersionCommand())
    
    let helpCommand = HelpCommand(registry: registry)
    registry.register(helpCommand)
    
    return registry
}
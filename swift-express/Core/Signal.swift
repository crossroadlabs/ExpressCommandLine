//
//===--- Signal.swift --------------------------------------------------===//
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
//===-------------------------------------------------------------------===//

import Foundation

enum Signal:Int32 {
    case HUP    = 1
    case INT    = 2
    case QUIT   = 3
    case ABRT   = 6
    case KILL   = 9
    case ALRM   = 14
    case TERM   = 15
}

typealias SigactionHandler = @convention(c)(Int32) -> Void

func trap_signal(signum:Signal, action:SigactionHandler) {
    var sigAction = sigaction()
    
    #if os(Linux)
        sigAction.__sigaction_handler = unsafeBitCast(action, sigaction.__Unnamed_union___sigaction_handler.self)
    #else
        sigAction.__sigaction_u = unsafeBitCast(action, __sigaction_u.self)
    #endif
    
    sigaction(signum.rawValue, &sigAction, nil)
}

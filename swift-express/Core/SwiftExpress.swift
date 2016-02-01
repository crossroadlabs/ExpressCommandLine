//
//  SwiftExpress.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/27/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Commandant

enum SwiftExpressError : ErrorType {
    case SubtaskError(message: String)
    case SomeNSError(error: NSError)
    case BadOptions(message: String)
}

func commandRegistry() -> CommandRegistry<SwiftExpressError> {
    let registry = CommandRegistry<SwiftExpressError>()
    
    //Commands
    registry.register(AppCommand())
    
    return registry
}
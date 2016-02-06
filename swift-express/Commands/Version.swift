//
//  Version.swift
//  swift-express
//
//  Created by Yegor Popovych on 2/6/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Commandant
import Result

struct VersionCommand: CommandType {
    let verb = "version"
    let function = "Display the current version of Swift Express Command Line"
    
    func run(options: NoOptions<SwiftExpressError>) -> Result<(), SwiftExpressError> {
        #if os(OSX)
            print("Swift Express Command Line \(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!)")
        #endif
        return .Success(())
    }
}


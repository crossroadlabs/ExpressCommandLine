//
//  MultiStepCommand.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/28/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Commandant
import Result

protocol StepCommand : CommandType {
    typealias Options: OptionsType
    
    var step : Step { get }
    
    func getOptions(opts: Options) -> Result<[String:Any], SwiftExpressError>
}

extension StepCommand {
    func run(options: Options) -> Result<(), SwiftExpressError> {
        switch self.getOptions(options) {
        case .Success(let opts):
            do {
                try StepRunner(step: self.step).run(opts)
                print("Task: \"\(self.verb)\" done.")
                return Result(())
            } catch {
                return Result(error: error as! SwiftExpressError)
            }
        case .Failure(let err):
            return Result(error: err)
        }
    }
}
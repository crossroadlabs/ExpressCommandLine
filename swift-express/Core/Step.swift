//
//  Step.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/28/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Result


protocol Step {
    
    var dependsOn : [Step] { get }
    
    func run(params: [String: Any], combinedOutput: StepResponse) throws -> [String: Any]
    func cleanup(params:[String: Any], output: StepResponse) throws
    
    // Optional. Return unique string key for object
    func uniqueKey() -> String
    
    // Optional. Implement only if step depends on any another step and need to convert call parameters
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any]
    
    func revert(params:[String: Any], output: StepResponse, error: SwiftExpressError)
}

extension Step {
    // Default realisation of callParams. Return own params
    func callParams(ownParams: [String: Any], forStep: Step, previousStepsOutput: StepResponse) throws -> [String: Any] {
        return ownParams
    }
    
    // Default realization of revert. Forward call to cleanup
    func revert(params:[String: Any], output: StepResponse, error: SwiftExpressError) {
        try! self.cleanup(params, output: output)
    }
    
    // Default implementation of uniqueKey. Returns class name
    func uniqueKey() -> String {
        return String(self.dynamicType)
    }
}

class StepResponse {
    private let response:[String:Any]?
    
    let parents:[String: StepResponse]?
    
    init(response: [String: Any]) {
        self.response = response
        self.parents = nil
    }
    
    init(parents: [String: StepResponse]) {
        self.response = nil
        self.parents = parents
    }
    
    init(response: [String: Any], parents: [String: StepResponse]) {
        self.response = response
        self.parents = parents
    }
    
    func ownParam(key: String) -> Any? {
        if response != nil {
            if let val = response![key] {
                return val
            }
        }
        return nil
    }
    
    func parentsParam(key: String) -> Any? {
        if parents != nil {
            for (_, parent) in parents! {
                if let val = parent.ownParam(key) {
                    return val
                }
            }
            for (_, parent) in parents! {
                if let val = parent.parentsParam(key) {
                    return val
                }
            }
        }
        return nil
    }
    
    subscript(key: String) -> Any? {
        if response != nil {
            if let val = response![key] {
                return val
            }
        }
        if parents != nil {
            for (_, parent) in parents! {
                if let val = parent[key] {
                    return val
                }
            }
        }
        return nil
    }
}

struct StepRunner {
    private let _step: Step
    
    init(step: Step) {
        self._step = step
    }
    
    private func runRevert(step: Step, steps: [Step], params: [String: Any], combinedOutput: [String: StepResponse], error: SwiftExpressError) {
        for errStep in steps.reverse() {
            if let subParams = try? step.callParams(params, forStep: errStep, previousStepsOutput: combinedOutput[errStep.uniqueKey()]!) {
                errStep.revert(subParams, output: combinedOutput[errStep.uniqueKey()]!, error: error)
                if (step.dependsOn.count > 0) {
                    runRevert(errStep, steps: errStep.dependsOn, params: subParams, combinedOutput: combinedOutput[errStep.uniqueKey()]!.parents!, error: error)
                }
            } else {
                errStep.revert(params, output: combinedOutput[errStep.uniqueKey()]!, error: error)
                if (step.dependsOn.count > 0) {
                    runRevert(errStep, steps: errStep.dependsOn, params: params, combinedOutput: combinedOutput[errStep.uniqueKey()]!.parents!, error: error)
                }
            }
        }
    }
    
    private func runStep(step: Step, params: [String: Any]) throws -> StepResponse {
        var combinedOutput = [String : StepResponse]()
        for index in 0..<step.dependsOn.count {
            let prevStep = step.dependsOn[index]
            do {
                let prevParams = try step.callParams(params, forStep: prevStep, previousStepsOutput: StepResponse(parents: combinedOutput))
                combinedOutput[prevStep.uniqueKey()] = try runStep(prevStep, params: prevParams)
            } catch {
                runRevert(step, steps: Array(step.dependsOn[0..<index]), params: params, combinedOutput: combinedOutput, error: error as! SwiftExpressError)
                throw error
            }
        }
        do {
            let response = try step.run(params, combinedOutput: StepResponse(parents: combinedOutput))
            return StepResponse(response: response, parents: combinedOutput)
        } catch {
            runRevert(step, steps: Array(step.dependsOn), params: params, combinedOutput: combinedOutput, error: error as! SwiftExpressError)
            throw error
        }
    }
    
    private func runCleanup(step: Step, params: [String: Any], output: StepResponse) throws {
        try step.cleanup(params, output: output)
        for index in (0..<step.dependsOn.count).reverse() {
            let parStep = step.dependsOn[index]
                
            let prevParams = try step.callParams(params, forStep: parStep, previousStepsOutput: output)
            try runCleanup(parStep, params: prevParams, output: output.parents![parStep.uniqueKey()]!)
        }
    }
    
    func run(params: [String: Any]) throws {
        let response = try runStep(self._step, params: params)
        do {
            try runCleanup(self._step, params: params, output: response)
        } catch {
            runRevert(self._step, steps: self._step.dependsOn, params: params, combinedOutput: response.parents!, error: error as! SwiftExpressError)
            throw error
        }
    }
}

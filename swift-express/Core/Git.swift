//
//  Git.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/28/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation

struct Git {
    static func cloneGitRepository(fromURL: String, toPath: String) throws {
        let task = SubTask(task: "/usr/bin/env", arguments: ["git", "clone", fromURL, toPath], environment: nil, readCallback: nil, finishCallback: nil)
        if task.runAndWait() != 0 {
            let message = try task.readErrorData().toString()
            throw SwiftExpressError.SubtaskError(message: message)
        }
    }
}
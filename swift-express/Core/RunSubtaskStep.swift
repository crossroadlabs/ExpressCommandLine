//===--- RunSubtaskStep.swift --------------------------------------------===//
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
//===----------------------------------------------------------------------===//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

protocol RunSubtaskStep : Step {
    func executeSubtaskAndWait(task: SubTask) throws -> Int32
}

extension RunSubtaskStep {
    func executeSubtaskAndWait(task: SubTask) throws -> Int32 {
        return try runSubTaskAndHandleSignals(task)
    }
}

// Can run only one task in app.
func runSubTaskAndHandleSignals(task: SubTask) throws -> Int32 {
    if !signalsRegistered {
        _registerSignals()
    }
    if currentRunningTask != nil {
        throw SwiftExpressError.SubtaskError(message: "Can't start new task. Some task already running")
    }
    defer {
        currentRunningTask = nil
    }
    currentRunningTask = task
    return try task.runAndWait()
}

private var currentRunningTask:SubTask? = nil
private var signalsRegistered:Bool = false

private func _registerSignals() {
    trap_signal(.INT, action: { signal -> Void in
        if currentRunningTask != nil {
            currentRunningTask!.interrupt()
            currentRunningTask = nil
        } else {
            exit(signal)
        }
    })
    trap_signal(.TERM, action: { signal -> Void in
        if currentRunningTask != nil {
            currentRunningTask!.terminate()
            currentRunningTask = nil
        } else {
            exit(signal)
        }
    })
    signalsRegistered = true
}
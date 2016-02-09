//===--- SubTask.swift ----------------------------------------------------===//
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

import Foundation
import SwiftTryCatch

extension dispatch_data_t {
    func toArray() -> [UInt8] {
        var bytes: UnsafePointer<Void> = nil
        var bytesLength:Int = 0
        guard dispatch_data_create_map(self, &bytes, &bytesLength) != nil else {
            return [UInt8]()
        }
        return Array<UInt8>(UnsafeMutableBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: bytesLength))
    }
}

class SubTask {
    private let task: String
    private let arguments: [String]
    private let readCb: ((SubTask, [UInt8], Bool) -> Bool)?
    private let finishCb: ((SubTask, Int32) -> ())?
    private var env:[String:String]?
    private let workingDirectory: String?
    
    private let nTask : NSTask
    
    /// A GCD group which to wait completion
    private static let group = dispatch_group_create()
    
    /// wait for all task termination
    static func waitForAllTaskTermination() {
        dispatch_group_wait(SubTask.group, DISPATCH_TIME_FOREVER)
    }
    
    init(task: String, arguments: [String]?, workingDirectory: String?, environment:[String:String]?, readCallback: ((task: SubTask, data:[UInt8], isError: Bool) -> Bool)?, finishCallback: ((task:SubTask, status:Int32) -> ())?) {
        self.task = task
        if arguments != nil {
            self.arguments = arguments!
        } else {
            self.arguments = [String]()
        }
        self.readCb = readCallback
        self.finishCb = finishCallback
        if environment == nil {
            self.env = Process.environment
            self.env!["NSUnbufferedIO"] = "YES"
        } else {
            self.env = environment
            self.env!["NSUnbufferedIO"] = "YES"
        }
        self.workingDirectory = workingDirectory
        
        nTask = NSTask()
    }
    
    func run() throws {
        nTask.launchPath = task
        nTask.arguments = arguments
        if env != nil {
            nTask.environment = env
        }
        if workingDirectory != nil {
            nTask.currentDirectoryPath = workingDirectory!
        }
        
        nTask.standardInput = NSPipe()
        nTask.standardOutput = NSPipe()
        nTask.standardError = NSPipe()
        
        dispatch_group_enter(SubTask.group)
        nTask.terminationHandler = { (fTask : NSTask) -> Void in
            if self.finishCb != nil {
                self.finishCb!(self, fTask.terminationStatus)
            }
            dispatch_group_leave(SubTask.group)
        }
        
        if readCb != nil {
            nTask.standardOutput!.fileHandleForReading.readabilityHandler = { fh in
                let data = fh.availableData
                if data.length != 0 {
                    if !self.readCb!(self, data.toArray(), false) {
                        self.terminate()
                    }
                }
            }
            nTask.standardError!.fileHandleForReading.readabilityHandler = { fh in
                let data = fh.availableData
                if data.length != 0 {
                    if !self.readCb!(self, data.toArray(), true) {
                        self.terminate()
                    }
                }
            }
        }
        
        var exception:NSException? = nil
        
        SwiftTryCatch.tryBlock({ () -> Void in
            self.nTask.launch()
        }, catchBlock: { (exc) -> Void in
            exception = exc
        }, finallyBlock: {})
        if exception != nil {
            throw SwiftExpressError.SubtaskError(message: "Task launch error: \(exception!)")
        }
    }
    
    func writeData(data: [UInt8]) {
        (nTask.standardInput! as! NSPipe).fileHandleForWriting.writeData(data.toData())
    }
    
    func readData() -> [UInt8] {
        return (nTask.standardOutput! as! NSPipe).fileHandleForReading.readDataToEndOfFile().toArray()
    }
    
    func readErrorData() -> [UInt8] {
        return (nTask.standardError! as! NSPipe).fileHandleForReading.readDataToEndOfFile().toArray()
    }
    
    func terminate() {
        nTask.terminate()
    }
    
    func interrupt() {
        nTask.interrupt()
    }
}

extension Process {
    static var environment:[String:String] {
        get {
            return NSProcessInfo.processInfo().environment
        }
    }
}



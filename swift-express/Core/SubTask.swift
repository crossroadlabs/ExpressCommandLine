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

class SubTask {
    private let task: String
    private let arguments: [String]?
    private let readCb: ((SubTask, [UInt8], Bool) -> Bool)?
    private let finishCb: ((SubTask, Int32) -> ())?
    private let env:[String:String]?
    
    private let nTask : NSTask
    
    init(task: String, arguments: [String]?, environment:[String:String]?, readCallback: ((task: SubTask, data:[UInt8], isError: Bool) -> Bool)?, finishCallback: ((task:SubTask, status:Int32) -> ())?) {
        self.task = task
        self.arguments = arguments
        self.readCb = readCallback
        self.finishCb = finishCallback
        self.env = environment
        nTask = NSTask()
    }
    
    func run() {
        nTask.launchPath = task
        nTask.arguments = arguments
        if env != nil {
            nTask.environment = env
        }
        
        nTask.standardInput = NSPipe()
        
        let readingPipe = NSPipe()
        nTask.standardOutput = readingPipe
        
        let errorPipe = NSPipe()
        nTask.standardError = errorPipe
        
        if readCb != nil {
            readingPipe.fileHandleForReading.readabilityHandler = { (fh) -> Void in
                let data = fh.availableData
                if data.length > 0 {
                    if !self.readCb!(self, data.toArray(), false) {
                        self.terminate()
                    }
                }
            }
            errorPipe.fileHandleForReading.readabilityHandler = { (fh) -> Void in
                let data = fh.availableData
                if data.length > 0 {
                    if !self.readCb!(self, data.toArray(), true) {
                        self.terminate()
                    }
                }
            }
        }
        if finishCb != nil {
            nTask.terminationHandler = { (fTask : NSTask) -> Void in
                self.finishCb!(self, fTask.terminationStatus)
            }
        }
        nTask.launch()
    }
    
    func wait() -> Int32 {
        nTask.waitUntilExit()
        return nTask.terminationStatus
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
    
    func runAndWait() -> Int32 {
        run()
        return wait()
    }
}

extension Process {
    static var environment:[String:String] {
        get {
            return NSProcessInfo.processInfo().environment
        }
    }
}



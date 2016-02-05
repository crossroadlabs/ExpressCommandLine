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
    private let arguments: [String]
    private let readCb: ((SubTask, [UInt8], Bool) -> Bool)?
    private let finishCb: ((SubTask, Int32) -> ())?
    private let env:[String:String]?
    private var finished:Bool
    
    private let nTask : NSTask
    private let queue : dispatch_queue_t?
    
    init(task: String, arguments: [String]?, environment:[String:String]?, readCallback: ((task: SubTask, data:[UInt8], isError: Bool) -> Bool)?, finishCallback: ((task:SubTask, status:Int32) -> ())?) {
        self.task = task
        if arguments != nil {
            self.arguments = arguments!
        } else {
            self.arguments = [String]()
        }
        self.readCb = readCallback
        self.finishCb = finishCallback
        self.env = environment
        finished = false
        nTask = NSTask()
        if self.readCb != nil {
            queue = dispatch_queue_create(task, DISPATCH_QUEUE_SERIAL)
        } else {
            queue = nil
        }
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
        
        nTask.terminationHandler = { (fTask : NSTask) -> Void in
            self.finished = true
            if self.finishCb != nil {
                self.finishCb!(self, fTask.terminationStatus)
            }
        }
        nTask.launch()
        
        if readCb != nil {
            let inputIo = dispatch_io_create(DISPATCH_IO_STREAM, readingPipe.fileHandleForReading.fileDescriptor, queue!, { (result) -> Void in })
            dispatch_io_read(inputIo, 0, Int.max, queue!, { (end, data, error) -> Void in
                if dispatch_data_get_size(data) > 0 {
                    if !self.readCb!(self, (data as! NSData).toArray(), false) {
                        self.terminate()
                    }
                }
            })
            
            let errorIo = dispatch_io_create(DISPATCH_IO_STREAM, errorPipe.fileHandleForReading.fileDescriptor, queue!, { (result) -> Void in })
            dispatch_io_read(errorIo, 0, Int.max, queue!, { (end, data, error) -> Void in
                if dispatch_data_get_size(data) > 0 {
                    if !self.readCb!(self, (data as! NSData).toArray(), true) {
                        self.terminate()
                    }
                }
            })
        }
        
    }
    
    func wait() -> Int32 {
        nTask.waitUntilExit()
        finished = true
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



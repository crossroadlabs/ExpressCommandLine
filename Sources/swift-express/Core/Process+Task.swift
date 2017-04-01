//===--- Process+Task.swift -------------------------------------------------===//
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
//===------------------------------------------------------------------------===//

import Foundation
#if !os(Linux)
    import SwiftTryCatch
#endif

extension Process {
    convenience public init(task: String, arguments: [String]? = nil, workingDirectory: URL? = nil, environment:[String:String]? = nil, useAppOutput: Bool = false, finishCallback: ((Process, Int32) -> Void)? = nil) {
        self.init()
        
        self.launchPath = task
        if let arguments = arguments {
            self.arguments = arguments
        }
        if let env = environment {
            self.environment = env
        }
        
        if let dir = workingDirectory {
            self.currentDirectoryPath = dir.path
        }
        
        if let finishCb = finishCallback {
            self.terminationHandler = { p in
                finishCb(p, p.terminationStatus)
            }
        }
        
        self.standardInput = Pipe()
        if useAppOutput {
            self.standardOutput = FileHandle.standardOutput
            self.standardError = FileHandle.standardError
        } else {
            self.standardOutput = Pipe()
            self.standardError = Pipe()
        }
    }
    
    func run() throws {
        #if !os(Linux)
            var error: NSException? = nil
            SwiftTryCatch.try({
                self.launch()
            }, catch: { exc in
                error = exc
            }, finallyBlock: {})
            if let error = error {
                throw SwiftExpressError.subtaskError(message: "\(error.name): \(error.reason ?? ""), \(error.userInfo ?? [:])")
            }
        #else
            let path = FileManager.default.currentDirectoryPath
            FileManager.default.changeCurrentDirectoryPath(self.currentDirectoryPath)
            launch()
            FileManager.default.currentDirectoryPath(path)
        #endif
    }
    
    func runAndWait() throws -> Int32 {
        try run()
        waitUntilExit()
        return terminationStatus
    }
    
    func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            write(data: data)
        }
    }
    
    func write(data: Data) {
        if let input = standardInput as? Pipe {
            input.fileHandleForWriting.write(data)
        }
    }
    
    func read() -> Data? {
        if let output = standardOutput as? Pipe {
            return output.fileHandleForReading.readDataToEndOfFile()
        }
        return nil
    }
    
    func readString() -> String? {
        return read().flatMap{String(data: $0, encoding: .utf8)}
    }
    
    func readError() -> Data? {
        if let error = standardError as? Pipe {
            return error.fileHandleForReading.readDataToEndOfFile()
        }
        return nil
    }
    
    func readErrorString() -> String? {
        return readError().flatMap{String(data: $0, encoding: .utf8)}
    }
}

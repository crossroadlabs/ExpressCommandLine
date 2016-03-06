//===--- FileOperations.swift ------------------------------------------===//
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
//===-------------------------------------------------------------------===//

import Foundation
import Regex
#if os(Linux)
    import Glibc
#endif

enum FileOpenMode {
    case Read
    case Write
    case Append
}

class File {
    private var file: NSFileHandle? = nil
    let path: String
    let mode: FileOpenMode
    
    init(path: String, mode: FileOpenMode = .Read) throws {
        self.path = path
        self.mode = mode
        let url = NSURL(fileURLWithPath: path)
        switch mode {
        case .Read:
            file = try NSFileHandle(forReadingFromURL: url)
        case .Write:
            file = try NSFileHandle(forWritingToURL: url)
        case .Append:
            file = try NSFileHandle(forUpdatingURL: url)
        }
    }
    
    deinit {
        file?.synchronizeFile()
        file?.closeFile()
    }
    
    func read(length: Int) -> [UInt8] {
        return file!.readDataOfLength(length).toArray()
    }
    
    func write(data: [UInt8]) throws {
        file!.writeData(data.toData())
    }
    
    func readToEnd() -> [UInt8] {
        return file!.readDataToEndOfFile().toArray()
    }
    
    func seek(position: UInt64) {
        file!.seekToFileOffset(position)
    }
    
    func seekToEnd() {
        file!.seekToEndOfFile()
    }
    
    func position() -> UInt64 {
        return file!.offsetInFile
    }
    
    func resize(size: UInt64) {
        file!.truncateFileAtOffset(size)
    }
}

struct FileManager {
    // Copy not implemented on Linux, so this is own implementation
    private static func copyFile(atPath: String, toPath: String) throws {
        let inFile = try File(path: atPath)
        if !isFileExists(toPath) {
            NSFileManager.defaultManager().createFileAtPath(toPath, contents: nil, attributes: nil)
        }
        let outFile = try File(path: toPath, mode: .Write)
        var bytes = inFile.read(4096)
        while bytes.count > 0 {
            try outFile.write(bytes)
            bytes = inFile.read(4096)
        }
    }
    
    private static func copyDirectory(atPath: String, toPath: String) throws {
        if !isDirectoryExists(toPath) {
            try createDirectory(toPath, createIntermediate: true)
        }
        for item in try listDirectory(atPath) {
            let itemPath = atPath.addPathComponent(item)
            if isFileExists(itemPath) {
                try copyFile(itemPath, toPath: toPath.addPathComponent(item))
            } else {
                try copyDirectory(itemPath, toPath: toPath.addPathComponent(item))
            }
        }
    }
    
    static func createDirectory(path: String, createIntermediate: Bool) throws {
        try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: path), withIntermediateDirectories: createIntermediate, attributes: nil)
    }
    
    static func removeItem(path: String) throws {
        try NSFileManager.defaultManager().removeItemAtURL(NSURL(fileURLWithPath: path))
    }
    
    static func copyItem(atPath: String, toDirectory: String) throws {
        let toPath = toDirectory.addPathComponent(atPath.lastPathComponent())
        if isFileExists(atPath) {
            try copyFile(atPath, toPath: toPath)
        } else {
            try copyDirectory(atPath, toPath: toPath)
        }
        //Not implemented in linux. Using own implementation
        //try NSFileManager.defaultManager().copyItemAtURL(NSURL(fileURLWithPath: atPath), toURL: NSURL(fileURLWithPath: toPath))
    }
    
    static func listDirectory(path: String) throws -> [String] {
        return try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
    }
    
    static func isFileExists(path: String) -> Bool {
        var isDir: ObjCBool = false
        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && !isDir
    }
    
    static func isDirectoryExists(path: String) -> Bool {
        var isDir: ObjCBool = false
        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && isDir
    }
    
    static func moveItem(atPath: String, toPath: String) throws {
        // Foundation implementation crashes on Linux. Using own implementation
        if rename(atPath, toPath) != 0 {
            if errno == EXDEV {
                let dir = toPath.removeLastPathComponent()
                try copyItem(atPath, toDirectory: dir)
                try moveItem(dir.addPathComponent(atPath.lastPathComponent()), toPath: toPath)
                try removeItem(atPath)
            } else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [NSFilePathErrorKey:atPath])
            }
        }
    }
    
    static func renameItem(path: String, newName: String) throws {
        let dir = path.removeLastPathComponent()
        try moveItem(path, toPath: dir.addPathComponent(newName))
    }
    
    static func currentWorkingDirectory() -> String {
        return NSFileManager.defaultManager().currentDirectoryPath
    }
    
    static func temporaryDirectory() -> String {
        return NSTemporaryDirectory()
    }
    
    static func homeDirectory() -> String {
        return NSHomeDirectory()
    }
}


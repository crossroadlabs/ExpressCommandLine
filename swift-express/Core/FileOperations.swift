//
//  FileOperations.swift
//  swift-express
//
//  Created by Yegor Popovych on 1/28/16.
//  Copyright © 2016 Crossroad Labs. All rights reserved.
//

import Foundation
import Regex

enum FileOpenMode {
    case Read
    case Write
    case Append
}

extension Array where Element:SEByte {
    func toData() -> NSData {
        return NSData(bytes: self, length: self.count)
    }
    static func fromData(data: NSData) -> Array<UInt8> {
        return data.toArray()
    }
}

extension NSData {
    func toArray() -> [UInt8] {
        return Array<UInt8>(UnsafeBufferPointer(start: UnsafePointer<UInt8>(self.bytes), count: self.length))
    }
    static func fromArray(array: [UInt8]) -> NSData {
        return array.toData()
    }
    static func fromArray(array: [Int8]) -> NSData {
        return array.toData()
    }
}

extension String {
    
    func ltrim(char: Character = " ") -> String {
        var index = 0
        for c in characters {
            if c != char {
                break
            }
            index++
        }
        return substringFromIndex(characters.startIndex.advancedBy(index))
    }
    
    func rtrim(char: Character = " ") -> String {
        var index = 0
        for c in characters.reverse() {
            if c != char {
                break
            }
            index++
        }
        return substringToIndex(characters.endIndex.advancedBy(-index))
    }
    
    func trim(char: Character = " ") -> String {
        return ltrim(char).rtrim(char)
    }
    
    func addPathComponent(component: String) -> String {
        let trimmed = component.trim("/")
        let selftrimed = rtrim("/")
        return selftrimed + "/" + trimmed
    }
    
    func removeLastPathComponent() -> String {
        let trimmed = rtrim("/")
        var index = 0
        for c in trimmed.characters.reverse() {
            if c == "/" {
                break;
            }
            index++
        }
        return trimmed.substringToIndex(characters.endIndex.advancedBy(-index))
    }
    
    func lastPathComponent() -> String {
        let trimmed = rtrim("/")
        var index = 0
        for c in trimmed.characters.reverse() {
            if c == "/" {
                break;
            }
            index++
        }
        return trimmed.substringFromIndex(characters.endIndex.advancedBy(-index))
    }
    
    func toArray() -> [UInt8] {
        return Array<UInt8>(utf8)
    }
    
    
    private static let _curDirR = "\\/\\.\\/|\\/\\.$|^\\.\\/".r!
    private static let _topDirR = "[^\\/\\?\\%\\*\\:\\|\"<>\\.]+/\\.\\.".r!
    
    func standardizedPath() -> String {
        if characters.count == 0 {
            return self
        }
        var output = trim().rtrim("/")
        if output.characters[output.characters.startIndex] == "~" {
            output = FileManager.homeDirectory().addPathComponent(output.ltrim("~"))
        }
        if output.characters[output.characters.startIndex] != "/" {
            output = FileManager.currentWorkingDirectory().addPathComponent(output)
        }
        return String._curDirR.replaceAll(String._topDirR.replaceAll(output, replacement: ""), replacement: "")
    }
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
        file!.synchronizeFile()
        file!.closeFile()
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
    
    static func createDirectory(path: String, createIntermediate: Bool) throws {
        try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: path), withIntermediateDirectories: createIntermediate, attributes: nil)
    }
    
    static func removeItem(path: String) throws {
        try NSFileManager.defaultManager().removeItemAtURL(NSURL(fileURLWithPath: path))
    }
    
    static func copyItem(atPath: String, toDirectory: String) throws {
        let toPath = toDirectory.addPathComponent(atPath.lastPathComponent())
        try NSFileManager.defaultManager().copyItemAtURL(NSURL(fileURLWithPath: atPath), toURL: NSURL(fileURLWithPath: toPath))
    }
    
    static func listDirectory(path: String) throws -> [String] {
        return try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
    }
    
    static func moveItem(atPath: String, toPath: String) throws {
        try NSFileManager.defaultManager().moveItemAtPath(atPath, toPath: toPath)
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


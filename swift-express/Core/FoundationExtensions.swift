//===--- FoundationExtensions.swift -------------------------------------===//
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

protocol SEByte {}
extension UInt8 : SEByte {}
extension Int8 : SEByte {}

extension Array where Element:SEByte {
    func toString() throws -> String {
        if count == 0 {
            return ""
        }
        var arr:Array<Element> = self
        switch self[count-1] {
        case let char as Int8:
            if char != 0 {
                arr = self + [Int8(0) as! Element]
            }
        case let char as UInt8:
            if char != 0 {
                arr = self + [UInt8(0) as! Element]
            }
        default:
            arr = self
        }
        return String.fromCString(UnsafePointer<Int8>(arr))!
    }
    
    func toData() -> NSData {
        return NSData(bytes: self, length: self.count)
    }
    
    static func fromData(data: NSData) -> Array<UInt8> {
        return data.toArray()
    }
}

extension String {
    static func fromArray(array: [UInt8]) throws -> String {
        return try array.toString()
    }
    
    static func fromArray(array: [Int8]) throws -> String {
        return try array.toString()
    }
    
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
        return String._curDirR.replaceAll(String._topDirR.replaceAll(output, replacement: ""), replacement: "/")
    }
}

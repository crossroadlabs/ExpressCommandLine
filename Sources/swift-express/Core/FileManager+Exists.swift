//===--- FileManager+Exists.swift -------------------------------------------===//
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

extension FileManager {
    func directoryExists(at URL: URL) -> Bool {
        do {
            let attrs = try attributesOfItem(atPath: URL.path)
            return attrs[FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeDirectory
        } catch {
            return false;
        }
    }
    
    func fileExists(at URL: URL) -> Bool {
        do {
            let attrs = try attributesOfItem(atPath: URL.path)
            return attrs[FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeRegular
        } catch {
            return false;
        }
    }
    
    var tempDirectory: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    #if os(Linux)
    func _copyItem(at srcURL: URL, to dstURL: URL) throws {
        if fileExists(at: srcURL) {
            try copyFile(at: srcURL, to: dstURL)
        } else {
            try copyDirectory(at: srcURL, to: dstURL)
        }
    }
    
    private func copyFile(at srcURL: URL, to dstURL: URL) throws {
        let inFile = try FileHandle(forReadingFrom: srcURL)
        defer {
            inFile.closeFile()
        }
        if !fileExists(at: dstURL) {
            FileManager.default.createFile(atPath: dstURL.path, contents: nil, attributes: nil)
        }
        let outFile = try FileHandle(forWritingTo: dstURL)
        defer {
            outFile.synchronizeFile()
            outFile.closeFile()
        }
        var bytes = inFile.readData(ofLength: 1024*1024)
        while bytes.count > 0 {
            outFile.write(bytes)
            bytes = inFile.readData(ofLength: 1024*1024)
        }
    }
    
    private func copyDirectory(at srcURL: URL, to dstURL: URL) throws {
        if !directoryExists(at: dstURL) {
            try createDirectory(at: dstURL, withIntermediateDirectories: true, attributes: nil)
        }
        for item in try contentsOfDirectory(at: srcURL, includingPropertiesForKeys: nil) {
            if fileExists(at: item) {
                try copyFile(at: item, to: dstURL.appendingPathComponent(item.lastPathComponent))
            } else {
                try copyDirectory(at: item, to: dstURL.appendingPathComponent(item.lastPathComponent))
            }
        }
    }
    #else
    func _copyItem(at srcURL: URL, to dstURL: URL) throws {
        try copyItem(at: srcURL, to: dstURL)
    }
    #endif
}

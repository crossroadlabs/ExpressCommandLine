//===--- Tests.swift ------------------------------===//
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
//===---------------------------------------------===//

import XCTest

class Tests: XCTestCase {
    
    func testArrayToString() {
        let arr:[UInt8] = [97, 98, 97, 99, 97, 98, 97, 0]
        let str = try! arr.toString()
        XCTAssert("abacaba" == str, "Array to string conversion error")
        
        let notClosedArr:[Int8] = [97, 98, 97, 99, 97, 98, 97]
        let notClosedStr = try! notClosedArr.toString()
        XCTAssertEqual(notClosedStr, "abacaba", "Array without trailing zero conversion error")
    }

}

#if os(Linux)
extension Tests : XCTestCaseProvider {
	var allTests : [(String, () throws -> Void)] {
		return [
			("testArrayToString", testArrayToString),
		]
	}
}
#endif
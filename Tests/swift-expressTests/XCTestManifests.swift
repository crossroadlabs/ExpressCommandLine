import XCTest

#if os(Linux)
public func allTests() -> [XCTestCaseEntry] {
	 return [
		testCase(Tests.allTests)
	]
}
#endif
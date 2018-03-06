import XCTest

import JWTProviderTests

var tests = [XCTestCaseEntry]()
tests += JWTProviderTests.allTests()
XCTMain(tests)
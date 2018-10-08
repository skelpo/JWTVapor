import XCTest

import JWTVaporTests

var tests = [XCTestCaseEntry]()
tests += JWTVaporTests.allTests()
tests += JWTProviderTests.allTests()
tests += JWKSServiceTests.allTests()
XCTMain(tests)

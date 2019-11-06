import XCTest

import JWTKitVaporTests

var tests = [XCTestCaseEntry]()
tests += JWTVaporTests.allTests()
tests += JWTProviderTests.allTests()
tests += JWKSServiceTests.allTests()
XCTMain(tests)

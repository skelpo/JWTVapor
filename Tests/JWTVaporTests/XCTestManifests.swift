import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JWTVaporTests.allTests),
        testCase(JWTProviderTests.allTests),
        testCase(JWKSServiceTests.allTests)
    ]
}
#endif

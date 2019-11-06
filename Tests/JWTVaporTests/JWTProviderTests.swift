//import XCTest
//import Vapor
//import JWTVapor
//
//final class JWTProviderTests: XCTestCase {
//    static let allTests = [("testItRegistersJWKSService", testItRegistersJWKSService)]
//    
//    func testItRegistersJWKSService() {
//        var services = Services()
//        
//        let mockJWKSConfig = JWKSConfig(jwks: "https://mockUrl.com", following: "jwks_mock_uri")
//        services.register(mockJWKSConfig)
//        try? services.register(JWTProvider(RSAService.self))
//        
//        let app = try? Application(services: services)
//        let jwksService = try? app?.make(JWKSService.self)
//        
//        XCTAssertNotNil(jwksService as Any)
//    }
//}

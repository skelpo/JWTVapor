import XCTest
import Vapor
import JWTVapor
import Core

final class JWKSServiceTests: XCTestCase {
    
    static let allTests = [
        ("testItThrowsErrorIfJWKSConfigIsNotRegisteredAsAService", testItThrowsErrorIfJWKSConfigIsNotRegisteredAsAService),
        ("testItDoesNotThrowErrorIfJWKSConfigIsRegisteredAsAService", testItDoesNotThrowErrorIfJWKSConfigIsRegisteredAsAService),
        ("testItReturnsAnRSAServiceForMentionedTid", testItReturnsAnRSAServiceForMentionedTid),
        ("testItThrowsAnErrorIfNoRSAServiceIsFoundForMentionedTid", testItThrowsAnErrorIfNoRSAServiceIsFoundForMentionedTid)
    ]
    
    func testItThrowsErrorIfJWKSConfigIsNotRegisteredAsAService() {
        var services = Services()
        try? services.register(JWTProvider(RSAService.self))
        let app = try? Application(services: services)
        
        XCTAssertThrowsError(try app?.make(JWKSService.self))
    }
    
    func testItDoesNotThrowErrorIfJWKSConfigIsRegisteredAsAService() {
        var services = Services()
        let jwksMockConfig = JWKSConfig(jwks: "https://mockurl.com", following: "jwks_mock_uri_key")
        services.register(jwksMockConfig)
        try? services.register(JWTProvider(RSAService.self))
        let app = try? Application(services: services)
        
        XCTAssertNoThrow(try app?.make(JWKSService.self))
    }
    
    func testItReturnsAnRSAServiceForMentionedTid() {
        var services = Services.default()
        let jwksMockConfig = JWKSConfig(jwks: "https://mockurl.com", following: "jwks_mock_uri_key")
        services.register(jwksMockConfig)
        services.register(JWKSMockClient.self)
        try? services.register(JWTProvider(RSAService.self))
        
        var config = Config.default()
        config.prefer(JWKSMockClient.self, for: Client.self)
        
        let app = try! Application(config: config, services: services)
        
        do {
            let rsaService = try app.make(JWKSService.self)
                                  .rsaService(forKey: "7_Zuf1tvkwLxYaHS3q6lUjUYIGw")
                                  .wait()
            
            XCTAssertEqual(rsaService.signer.algorithm.jwtAlgorithmName, "RS256")
            
        } catch {
            
            XCTFail("Failed with exception \(error)")
        }
    }
    
    func testItThrowsAnErrorIfNoRSAServiceIsFoundForMentionedTid() {
        var services = Services.default()
        let jwksMockConfig = JWKSConfig(jwks: "https://mockurl.com", following: "jwks_mock_uri_key")
        services.register(jwksMockConfig)
        services.register(JWKSMockClient.self)
        try? services.register(JWTProvider(RSAService.self))
        
        var config = Config.default()
        config.prefer(JWKSMockClient.self, for: Client.self)
        
        let app = try! Application(config: config, services: services)
        
        XCTAssertThrowsError(try app.make(JWKSService.self)
                                    .rsaService(forKey: "some_unknown_tid")
                                    .wait())
    }
}

import Vapor
import JWT

public class Provider: Vapor.Provider {
    public static var repositoryName: String = "JWTProvider"
    
    public let serviceBuilder: (String) -> JWTService
    
    public init (serviceBuilder: @escaping (String) -> JWTService) {
        self.serviceBuilder = serviceBuilder
    }
    
    public func register(_ services: inout Services) throws {
        guard let secret = Environment.get("JWT_SECRET") else {
            throw JWTProviderError(identifier: "noSecretFound", reason: "No 'JTW_SECRET' environment variable was found")
        }
        
        let jwtService = serviceBuilder(secret)
        if let rsaService = jwtService as? RSAService {
            services.register(rsaService)
        } else if let hmacService = jwtService as? HMACService {
            services.register(hmacService)
        } else {
            throw JWTProviderError(identifier: "unsupportedJWTService", reason: "The registered JWT service is not supported. Maybe you created a custom service?")
        }
    }
    
    public func boot(_ worker: Container) throws {}
}

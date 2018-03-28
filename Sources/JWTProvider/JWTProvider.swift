import Vapor
@_exported import JWT

public class Provider: Vapor.Provider {
    public static var repositoryName: String = "JWTProvider"
    
    public let serviceBuilder: (String) -> JWTService
    
    public init (serviceBuilder: @escaping (String) -> JWTService) {
        self.serviceBuilder = serviceBuilder
    }
    
    public func register(_ services: inout Services) throws {
        guard let secret = Environment.get("JWT_SECRET") else {
            throw JWTProviderError(identifier: "noSecretFound", reason: "No 'JWT_SECRET' environment variable was found", status: .internalServerError)
        }
        
        let jwtService = serviceBuilder(secret)
        if let rsaService = jwtService as? RSAService {
            services.register(rsaService, as: JWTService.self)
        } else if let hmacService = jwtService as? HMACService {
            services.register(hmacService, as: JWTService.self)
        } else {
            throw JWTProviderError(
                identifier: "unsupportedJWTService",
                reason: "The registered JWT service is not supported. Maybe you created a custom service?",
                status: .internalServerError
            )
        }
    }
    
    public func boot(_ worker: Container) throws {}
    
    public func didBoot(_ worker: Container) throws -> EventLoopFuture<Void> { return Future.map(on: worker, { () }) }
}

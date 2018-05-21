import Vapor
@_exported import JWT

public class JWTProvider: Vapor.Provider {
    public static var repositoryName: String = "JWTProvider"
    
    public let serviceBuilder: (String)throws -> JWTService
    
    public init (serviceBuilder: @escaping (String)throws -> JWTService) {
        self.serviceBuilder = serviceBuilder
    }
    
    public init(_ serviceType: JWTService.Type)throws {
        self.serviceBuilder = { secret in
            switch serviceType {
            case is RSAService.Type: return try RSAService(n: secret, e: "AQAB")
            case is HMACService.Type: return try HMACService(secret: secret)
            case is CertService.Type: return try CertService(certificate: secret)
            default:
                throw JWTProviderError(
                    identifier: "unsupportedJWTService",
                    reason: "The registered JWT service is not supported. Maybe you created a custom service?",
                    status: .internalServerError
                )
            }
        }
    }
    
    public func register(_ services: inout Services) throws {
        guard let secret = Environment.get("JWT_SECRET") else {
            throw JWTProviderError(identifier: "noSecretFound", reason: "No 'JWT_SECRET' environment variable was found", status: .internalServerError)
        }
        
        let jwtService = try serviceBuilder(secret)
        if let rsaService = jwtService as? RSAService {
            services.register(rsaService, as: JWTService.self)
        } else if let hmacService = jwtService as? HMACService {
            services.register(hmacService, as: JWTService.self)
        } else if let certService = jwtService as? CertService {
            services.register(certService, as: JWTService.self)
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

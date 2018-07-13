import Vapor
@_exported import JWT

public class JWTProvider: Vapor.Provider {
    public static var repositoryName: String = "JWTProvider"
    
    public let serviceBuilder: (String, String?)throws -> JWTService
    
    public init (serviceBuilder: @escaping (String, String?)throws -> JWTService) {
        self.serviceBuilder = serviceBuilder
    }
    
    public init(_ serviceType: JWTService.Type)throws {
        self.serviceBuilder = { key, d in
            switch serviceType {
            case is RSAService.Type:
                return try RSAService(n: key, e: "AQAB", d: d)
            case is HMACService.Type: return try HMACService(key: key)
            case is CertService.Type: return try CertService(certificate: key)
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
        let d = Environment.get("JWT_SECRET")
        guard let key = Environment.get("JWT_PUBLIC") else {
            throw JWTProviderError(identifier: "noSecretFound", reason: "No 'JWT_SECRET' environment variable was found", status: .internalServerError)
        }
        
        let jwtService = try serviceBuilder(key, d)
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

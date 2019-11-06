import Vapor
@_exported import JWTKit

public class JWTProvider: Vapor.Provider {
    public enum Algorithm {
        case rsa
        case hmac
        case cert
        case custom((String, String?) throws -> JWTService)
    }

    public let algorithm: Algorithm
    public let secretVar: String
    public let publicVar: String

    public init(algorithm: Algorithm, secretVar: String? = nil, publicVar: String? = nil) {
        self.algorithm = algorithm
        self.secretVar = secretVar ?? "JWT_SECRET"
        self.publicVar = publicVar ?? "JWT_PUBLIC"
    }

    public func service() throws -> JWTService {
        guard let publicKey = Environment.get(self.publicVar) else {
            throw JWTProviderError(
                identifier: "missingPublicKey",
                reason: "No value was found at the given public key environment variable, '\(self.publicVar)'",
                status: .internalServerError
            )
        }

        switch self.algorithm {
        case .rsa: return try RSAService(n: publicKey, e: "AQAB", d: Environment.get(self.secretVar))
        case .hmac: return try HMACService(key: publicKey)
        case .cert: return try CertService(certificate: Data(publicKey.utf8))
        case let .custom(closure): return try closure(publicKey, Environment.get(self.secretVar))
        }
    }

    public func register(_ app: Application) {
        app.register(JWTService.self, { _ in try self.service() })
        app.register(request: JWTService.self, { _ in try self.service() })
    }
}

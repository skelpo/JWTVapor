import Vapor
@_exported import JWTKit

public class JWTProvider: Vapor.Provider {
    public enum Algorithm {
        case rsa(DigestAlgorithm = .sha256)
        case hmac(DigestAlgorithm = .sha256)
        case cert(DigestAlgorithm = .sha256)
        case custom((JWTHeader?, String, String?) throws -> JWTService)
    }

    public let algorithm: Algorithm
    public let header: JWTHeader?
    public let secretVar: String
    public let publicVar: String

    public init(algorithm: Algorithm, header: JWTHeader?, secretVar: String? = nil, publicVar: String? = nil) {
        self.algorithm = algorithm
        self.header = header
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
        case let .rsa(alorithm): return try RSAService(n: publicKey, e: "AQAB", d: Environment.get(self.secretVar), header: self.header, algorithm: alorithm)
        case let .hmac(alorithm): return try HMACService(key: publicKey, header: self.header, algorithm: alorithm)
        case let .cert(alorithm): return try CertService(certificate: Data(publicKey.utf8), header: self.header, algorithm: alorithm)
        case let .custom(closure): return try closure(self.header, publicKey, Environment.get(self.secretVar))
        }
    }

    public func register(_ app: Application) {
        app.register(JWTService.self, { _ in try self.service() })
        app.register(request: JWTService.self, { _ in try self.service() })
    }
}

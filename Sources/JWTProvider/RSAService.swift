import Foundation
import Crypto
import JWT

public final class RSAService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader
    
    public init(secret: String, header: JWTHeader, type: RSAKeyType = .private, algorithm: DigestAlgorithm = .sha256)throws {
        let key: RSAKey
        switch type {
        case .public: key = try RSAKey.public(pem: secret)
        case .private: key = try RSAKey.private(pem: secret)
        }
        
        switch Int(algorithm.type) {
        case Int(DigestAlgorithm.sha256.type): self.signer = JWTSigner.rs256(key: key)
        case Int(DigestAlgorithm.sha384.type): self.signer = JWTSigner.rs384(key: key)
        case Int(DigestAlgorithm.sha512.type): self.signer = JWTSigner.rs512(key: key)
        default: throw JWTProviderError(identifier: "badRSAAlgorithm", reason: "RSA signing requires SHA256, SHA384, or SHA512 algorithm", status: .internalServerError)
        }
        
        self.header = header
    }
    
    public init(
        secret: String,
        header: JWTHeader,
        keyBuilder: (LosslessDataConvertible)throws -> RSAKey = RSAKey.private,
        signerBuilder: (RSAKey) -> JWTSigner = JWTSigner.rs256
    )throws {
        let key = try keyBuilder(secret)
        self.signer = signerBuilder(key)
        self.header = header
    }
}


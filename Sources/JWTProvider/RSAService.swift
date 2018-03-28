import Foundation
import Crypto
import JWT

public final class RSAService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader
    
    public init(secret: String, header: JWTHeader, type: RSAKeyType = .private, algorithm: DigestAlgorithm = .sha256)throws {
        let key = try RSAKey.private(pem: secret)
        let rsa = RSA(digestAlgorithm: algorithm, key: key)
        self.signer = JWTSigner(algorithm: rsa)
        self.header = header
    }
    
    public init(secret: String, header: JWTHeader, keyBuilder: (LosslessDataConvertible) -> RSAKey, signerBuilder: (RSAKey) -> JWTSigner = JWTSigner.rs256) {
        let key = keyBuilder(secret)
        self.signer = signerBuilder(key)
        self.header = header
    }
}


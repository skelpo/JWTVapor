import Foundation
import Crypto
import JWT

public final class RSAService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader
    
    public init(secret: String, header: JWTHeader, bits: Int, type: RSAKeyType = .private, algorithm: RSAHashAlgorithm = .sha256) {
        let key = RSAKey(bits: bits, type: type, data: Data(secret.utf8))
        let rsa = RSA(hashAlgorithm: algorithm, key: key)
        self.signer = JWTSigner(algorithm: rsa)
        self.header = header
    }
    
    public init(secret: String, header: JWTHeader, keyBuilder: (Data) -> RSAKey, signerBuilder: (RSAKey) -> JWTSigner = JWTSigner.rs256) {
        let key = keyBuilder(Data(secret.utf8))
        self.signer = signerBuilder(key)
        self.header = header
    }
}


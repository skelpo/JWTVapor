import Foundation
import Crypto
import JWT

public final class HMACService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader
    
    public init(secret: String, header: JWTHeader = .init(), algorithm: DigestAlgorithm = .sha256)throws {
        switch Int(algorithm.type) {
        case Int(DigestAlgorithm.sha256.type): self.signer = JWTSigner.hs256(key: Data(secret.utf8))
        case Int(DigestAlgorithm.sha384.type): self.signer = JWTSigner.hs384(key: Data(secret.utf8))
        case Int(DigestAlgorithm.sha512.type): self.signer = JWTSigner.hs512(key: Data(secret.utf8))
        default: throw JWTProviderError(identifier: "badHMACAlgorithm", reason: "HMAC signing requires SHA256, SHA384, or SHA512 algorithm", status: .internalServerError)
        }
        
        self.header = header
    }
    
    public init(secret: String, header: JWTHeader, signerBuilder: (Data) -> JWTSigner = JWTSigner.hs256) {
        self.signer = signerBuilder(Data(secret.utf8))
        self.header = header
    }
}

import Foundation
import Crypto
import JWT

public final class HMACService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader?
    
    public init(secret: String, header: JWTHeader? = nil, algorithm: DigestAlgorithm = .sha256)throws {
        switch algorithm {
        case .sha256: self.signer = JWTSigner.hs256(key: Data(secret.utf8))
        case .sha384: self.signer = JWTSigner.hs384(key: Data(secret.utf8))
        case .sha512: self.signer = JWTSigner.hs512(key: Data(secret.utf8))
        default: throw JWTProviderError(identifier: "badHMACAlgorithm", reason: "HMAC signing requires SHA256, SHA384, or SHA512 algorithm", status: .internalServerError)
        }
        
        self.header = header
    }
    
    public init(secret: String, header: JWTHeader?, signerBuilder: (Data) -> JWTSigner = JWTSigner.hs256) {
        self.signer = signerBuilder(Data(secret.utf8))
        self.header = header
    }
}

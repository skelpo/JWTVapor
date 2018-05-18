import Foundation
import Crypto
import JWT

public final class PEMService: JWTService {
    public var signer: JWTSigner
    public var header: JWTHeader?
    
    public init(certificate: String, header: JWTHeader? = nil, algorithm: DigestAlgorithm = .sha256)throws {
        let key = try RSAKey.public(certificate: certificate)
        
        switch algorithm {
        case .sha256: self.signer = JWTSigner.rs256(key: key)
        case .sha384: self.signer = JWTSigner.rs384(key: key)
        case .sha512: self.signer = JWTSigner.rs512(key: key)
        default: throw JWTProviderError(identifier: "badRSAAlgorithm", reason: "RSA signing requires SHA256, SHA384, or SHA512 algorithm", status: .internalServerError)
        }
        
        self.header = header
    }
}

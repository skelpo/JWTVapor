import Foundation
import JWTKit

public final class CertService: JWTService {
    public var signer: JWTSigner
    public var header: JWTHeader?
    
    public init(certificate: Data, header: JWTHeader? = nil, algorithm: DigestAlgorithm = .sha256)throws {
        let key = try RSAKey.public(pem: certificate)
        
        switch algorithm {
        case .sha256: self.signer = JWTSigner.rs256(key: key)
        case .sha384: self.signer = JWTSigner.rs384(key: key)
        case .sha512: self.signer = JWTSigner.rs512(key: key)
        }
        
        self.header = header
    }
}

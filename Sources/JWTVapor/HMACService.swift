import Foundation
import JWTKit

public final class HMACService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader?
    
    public init(key: String, header: JWTHeader? = nil, algorithm: DigestAlgorithm = .sha256)throws {
        switch algorithm {
        case .sha256: self.signer = JWTSigner.hs256(key: Data(key.utf8))
        case .sha384: self.signer = JWTSigner.hs384(key: Data(key.utf8))
        case .sha512: self.signer = JWTSigner.hs512(key: Data(key.utf8))
        }
        
        self.header = header
    }
    
    public init(key: String, header: JWTHeader?, signerBuilder: (Data) -> JWTSigner = JWTSigner.hs256) {
        self.signer = signerBuilder(Data(key.utf8))
        self.header = header
    }
}

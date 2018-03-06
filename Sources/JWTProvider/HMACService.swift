import Foundation
import Crypto
import JWT

public final class HMACService: JWTService {
    public let signer: JWTSigner
    public let header: JWTHeader
    
    public init(secret: String, header: JWTHeader, algorithm: HMACAlgorithmVariant = .sha256) {
        let hmac = HMACAlgorithm(algorithm, key: Data(secret.utf8))
        
        self.signer = JWTSigner(algorithm: hmac)
        self.header = header
    }
    
    public init(secret: String, header: JWTHeader, signerBuilder: (Data) -> JWTSigner = JWTSigner.hs256) {
        self.signer = signerBuilder(Data(secret.utf8))
        self.header = header
    }
}

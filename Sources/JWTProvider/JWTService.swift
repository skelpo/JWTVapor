import Foundation
import Service
import Crypto
import JWT

public protocol JWTService: Service {
    var signer: JWTSigner { get }
    var header: JWTHeader { get }
    
    func sign<T: JWTPayload>(_ payload: T)throws -> String
}

extension JWTService {
    public func sign<T>(_ payload: T) throws -> String where T : JWTPayload {
        var jwt = JWT.init(header: self.header, payload: payload)
        let data = try signer.sign(&jwt)
        guard let token = String(data: data, encoding: .utf8) else {
            throw JWTProviderError(
                identifier: "tokenEncodingFailed",
                reason: "Converting access token data to a string failed with UTF-8 encoding"
            )
        }
        return token
    }
}

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


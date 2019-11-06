import Foundation
import JWTKit

public protocol JWTService {
    var signer: JWTSigner { get }
    var header: JWTHeader? { get }
    
    func sign<T: JWTPayload>(_ payload: T)throws -> String
    func verify(_ token: Data)throws -> Bool
}

public enum DigestAlgorithm {
    case sha256, sha384, sha512
}


extension UInt8 {
    static let period: UInt8 = 46
}

extension JWTSigner {
    public func verify<S, H, P>(_ signature: S, header: H, payload: P) throws -> Bool
        where S: DataProtocol, H: DataProtocol, P: DataProtocol
    {
        let message: Data = Data(header) + Data([.period]) + Data(payload)
        guard let signature = Data(base64Encoded: Data(signature)) else {
            throw JWTError.malformedToken
        }
        return try algorithm.verify(signature, signs: message)
    }
}

extension JWTService {
    public func sign<T>(_ payload: T) throws -> String where T : JWTPayload {
        guard let header = self.header else {
            throw JWTProviderError(identifier: "noHeader", reason: "Cannot sign token with a header", status: .internalServerError)
        }

        let jwt = JWT(header: header, payload: payload)
        let bytes = try jwt.sign(using: self.signer)
        return String(decoding: bytes, as: UTF8.self)
    }
    
    public func verify(_ token: Data)throws -> Bool {
        let parts = token.split(separator: .period)
        guard parts.count == 3 else {
            throw JWTError.malformedToken
        }
        
        let header = Data(parts[0])
        let payload = Data(parts[1])
        let signature = Data(parts[2])

        return try self.signer.verify(signature, header: header, payload: payload)
    }
}

import Foundation
import Service
import Crypto
import JWT

public protocol JWTService: Service {
    var signer: JWTSigner { get }
    var header: JWTHeader? { get }
    
    func sign<T: JWTPayload>(_ payload: T)throws -> String
    func verify(_ token: Data)throws -> Bool
}

extension JWTService {
    public func sign<T>(_ payload: T) throws -> String where T : JWTPayload {
        guard let header = self.header else {
            throw JWTProviderError(identifier: "noHeader", reason: "Cannot sign token with a header", status: .internalServerError)
        }
        let jwt = JWT(header: header, payload: payload)
        let data = try signer.sign(jwt)
        guard let token = String(data: data, encoding: .utf8) else {
            throw JWTProviderError(
                identifier: "tokenEncodingFailed",
                reason: "Converting access token data to a string failed with UTF-8 encoding",
                status: .internalServerError
            )
        }
        return token
    }
    
    public func verify(_ token: Data)throws -> Bool {
        let parts = token.split(separator: .period)
        guard parts.count == 3 else {
            throw JWTError(identifier: "invalidJWT", reason: "Malformed JWT")
        }
        
        let header = Data(parts[0])
        let payload = Data(parts[1])
        let signature = Data(parts[2])
        
        return try self.signer.verify(signature, header: header, payload: payload)
    }
}

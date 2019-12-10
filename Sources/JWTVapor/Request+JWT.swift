import Vapor
import JWTKit

extension Request {
    var jwtService: JWTService {
        return self.application.jwtService
    }
}

extension Request {
    public func payload<Payload>(`as` type: Payload.Type = Payload.self)throws -> Payload where Payload: JWTPayload {
        guard let token = self.headers.bearerAuthorization?.token else {
            throw JWTProviderError(identifier: "missingAuthorizationHeader", reason: "'Authorization' header with bearer token is missing", status: .badRequest)
        }
        let data: Data = Data(token.utf8)
        
        if try self.jwtService.verify(data) {
            return try JWT<Payload>.init(from: data, verifiedBy: self.jwtService.signer).payload
        } else {
            throw JWTProviderError(identifier: "verificationFailed", reason: "Verification failed for JWT token", status: .forbidden)
        }
    }
}

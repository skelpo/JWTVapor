import Authentication
import Vapor
import JWT

extension Request {
    public func payload<Payload>()throws -> Payload where Payload: JWTPayload {
        guard let token = self.http.headers.bearerAuthorization?.token else {
            throw JWTProviderError(identifier: "missingAuthorizationHeader", reason: "'Authorization' header with bearer token is missing", status: .badRequest)
        }
        let jwt = try self.make(JWTService.self)
        let data: Data = Data(token.utf8)
        
        if try jwt.verify(data) {
            return try JWT<Payload>.init(from: data, verifiedUsing: jwt.signer).payload
        } else {
            throw JWTProviderError(identifier: "verificationFailed", reason: "Verification failed for JWT token", status: .forbidden)
        }
    }
}

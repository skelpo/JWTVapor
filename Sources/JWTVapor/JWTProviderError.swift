import Vapor

public struct JWTProviderError: AbortError, Error {
    public let identifier: String
    public let reason: String
    public let status: HTTPResponseStatus

    public var description: String {
        return "JWTProviderError.\(self.identifier): \(self.status) \(self.reason)"
    }
}

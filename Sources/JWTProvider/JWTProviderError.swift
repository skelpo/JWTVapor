import Debugging
import Vapor

public struct JWTProviderError: Debuggable, AbortError, Error {
    public let identifier: String
    public let reason: String
    public let status: HTTPResponseStatus
}

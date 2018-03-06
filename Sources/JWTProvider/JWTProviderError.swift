import Debugging

public struct JWTProviderError: Debuggable, Error {
    public let identifier: String
    public let reason: String
}

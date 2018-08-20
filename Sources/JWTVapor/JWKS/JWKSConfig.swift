import Foundation
import Vapor

/// Configuration required by the `JWKSService`.
/// The user needs to provide this configuration at the time of registering services in their `configure.swift` file.
///
/// Eg:
///
///     let jwks = "https://somedomain.com/v2.0/.well-known/openid-configuration"
///     let following = "jwks_uri"
///     services.register(JWKSConfig(jwks: jwks, following: following))
///

/// `JWKSConfig` is a `Service` which gets created by the required container and is made available
/// to `JWKSService` in its `makeService` method.
public struct JWKSConfig: Service {
    public let jwks: String
    public let following: String
    public let password: String?
    
    public init(jwks: String, following: String, password: String? = nil) {
        self.jwks = jwks
        self.following = following
        self.password = password
    }
}

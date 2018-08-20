import Foundation
import Vapor

public struct JWKSService: ServiceType {
    
    /// config: `JWKSConfig` instance which contains all the configurations required by `JWKSService`.
    private let config: JWKSConfig
    /// The service container in which the Services are to be loaded.
    private let container: Container
    
    /// Create a key that gets passed as a key in the `JSONDecoder.userInfo` dictionary and its value is
    /// value that the user passes in `JWKSConfig`'s `following`. The value passed in the `following`
    /// property is converted into a `CodingKey` type before passing in `JSONDecoder`'s userInfo.
    ///
    /// The userInfo dictionary is populated as follows:
    ///
    ///     [codingUserInfoKey: JWKSDocumentCodingKey(stringValue: self.config.following)]
    static let codingUserInfoKey = CodingUserInfoKey(rawValue: "jwksUrlKey")!
    
    public init(config: JWKSConfig, container: Container) {
        self.config = config
        self.container = container
    }
    
    /// Finds and returns a RSAService that matches the provided `tid` from the list of JWKS.
    /// The `tid` is obtained from the JWT Header of the incoming request, if the signing mechanism used is RSA.
    public func rsaService(forKey tid: String) throws -> Future<RSAService> {
        return try container.client().get(self.config.jwks).flatMap { response throws -> Future<JWKSDocumentRequest>  in
            
            /// Create a JSONDecoder in which the codingKey could be passed as part of userInfo.
            let jsonDecoder = JSONDecoder()
            let jwksUrlKey = JWKSDocumentCodingKey(stringValue: self.config.following)!
            jsonDecoder.userInfo = [JWKSService.codingUserInfoKey: jwksUrlKey]
            /// return the JSON response.
            return try response.content.decode(json: JWKSDocumentRequest.self, using: jsonDecoder)
            
        }.flatMap { jwksDocumentRequest throws -> Future<Response> in
            /// Make a request and return the JWKS file.
            return try self.container.client().get(jwksDocumentRequest.jwksUrl)
            
        }.flatMap { response throws -> Future<JWKSKeys> in
            /// Read the entire list of JWKS Keys.
            return try response.content.decode(JWKSKeys.self)
            
        }.map { jwksKeys throws -> JWKSKey in
            /// Search for JWKSKey that corresponds to the provided `tid`
            guard let matchingJWKSKey = jwksKeys.keys.filter({ $0.kid == tid }).first else {
                throw JWTProviderError(identifier: "invalidJWKSKeys", reason: "No matching key found in JWKS file", status: .internalServerError)
            }
            return matchingJWKSKey
            
        }.map { jwksKey throws -> RSAService in
            /// Create the RSAService using the JWKSKey.
            return try RSAService(n: jwksKey.n, e: jwksKey.e)
                
        }
    }
    
    public static func makeService(for worker: Container) throws -> JWKSService {
        // Load the required services.
        let config = try worker.make(JWKSConfig.self)
        return JWKSService(config: config, container: worker)
    }
}



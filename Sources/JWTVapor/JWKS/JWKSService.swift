import Foundation
import Vapor

public struct JWKSService {
    static let factory: (Application) throws -> JWKSService = { _ in fatalError() }
    static let requestFactory: (Request) throws -> JWKSService = { _ in fatalError() }

    /// Create a key that gets passed as a key in the `JSONDecoder.userInfo` dictionary and its value is
    /// value that the user passes in `JWKSConfig`'s `following`. The value passed in the `following`
    /// property is converted into a `CodingKey` type before passing in `JSONDecoder`'s userInfo.
    ///
    /// The userInfo dictionary is populated as follows:
    ///
    ///     [codingUserInfoKey: JWKSDocumentCodingKey(stringValue: self.config.following)]
    static let codingUserInfoKey = CodingUserInfoKey(rawValue: "jwksUrlKey")!


    /// config: `JWKSConfig` instance which contains all the configurations required by `JWKSService`.
    private let config: JWKSConfig

    /// The client we need to pull the jwks.
    private let client: Client

    public init(config: JWKSConfig, client: Client) {
        self.config = config
        self.client = client

    }

    /// Finds and returns a RSAService that matches the provided `tid` from the list of JWKS.
    /// The `tid` is obtained from the JWT Header of the incoming request, if the signing mechanism used is RSA.
    public func rsaService(forKey tid: String) throws -> EventLoopFuture<RSAService> {
        return self.client.get(self.config.jwks).flatMap { response -> EventLoopFuture<ClientResponse>  in
            let jsonDecoder = JSONDecoder()
            let jwksUrlKey = JWKSDocumentCodingKey(stringValue: self.config.following)!
            jsonDecoder.userInfo = [JWKSService.codingUserInfoKey: jwksUrlKey]

            do {
                let request = try response.content.decode(JWKSDocumentRequest.self, using: jsonDecoder)
                return self.client.get(request.jwksUrl)
            } catch let error {
                let eventLoop = self.client.eventLoopGroup.next()
                return eventLoop.future(error: error)
            }
        }.flatMapThrowing { response throws -> RSAService in
            /// Read the entire list of JWKS Keys.
            let jwksKeys = try response.content.decode(JWKSKeys.self)

            /// Search for JWKSKey that corresponds to the provided `tid`
            guard let matchingJWKSKey = jwksKeys.keys.filter({ $0.kid == tid }).first else {
                throw JWTProviderError(identifier: "invalidJWKSKeys", reason: "No matching key found in JWKS file", status: .internalServerError)
            }

            return try RSAService(n: matchingJWKSKey.n, e: matchingJWKSKey.e, d: matchingJWKSKey.d)
        }
    }

//    public static func makeService(for worker: Container) throws -> JWKSService {
//        // Load the required services.
//        let config = try worker.make(JWKSConfig.self)
//        return JWKSService(config: config, container: worker)
//    }
}



import Foundation
import Vapor

/// Content (Codeable) model to read the response obtained after hitting the url specified in the
/// `jwks` property of `JWKSConfig`.
public struct JWKSDocumentRequest: Content {
    let jwksUrl: URI

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JWKSDocumentCodingKey.self)
        
        // Read the coding key passed to the decoder as part of userinfo
        guard let jwksUrlKey = decoder.userInfo[JWKSService.codingUserInfoKey] as? JWKSDocumentCodingKey else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed"))
        }

        self.jwksUrl = try URI(string: container.decode(String.self, forKey: jwksUrlKey))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JWKSDocumentCodingKey.self)

        // Read the coding key passed to the decoder as part of userinfo
        guard let jwksUrlKey = encoder.userInfo[JWKSService.codingUserInfoKey] as? JWKSDocumentCodingKey else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed"))
        }

        try container.encode(self.jwksUrl.string, forKey: jwksUrlKey)
    }
}


/// Create a coding key which will represent the dynamic keyname provided by the user in the
/// `following` property of `JWKSConfig`.
public struct JWKSDocumentCodingKey: CodingKey {
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int? { return nil }
    
    public init?(intValue: Int) { return nil }
}

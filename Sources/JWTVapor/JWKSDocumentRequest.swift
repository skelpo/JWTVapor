import Foundation
import Vapor

/// Content (Codeable) model to read the response obtained after hitting the url specified in the
/// `jwks` property of JWKSConfig.
public struct JWKSDocumentRequest: Content {
    let jwksUrl: String
    
    public init(from decoder: Decoder) throws {
        // Get the container
        let container = try decoder.container(keyedBy: JWKSDocumentCodingKey.self)
        
        // Read the coding key passed to the decoder as part of userinfo
        guard let jwksUrlKey = decoder.userInfo[JWKSService.codingUserInfoKey] as? JWKSDocumentCodingKey else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed"))
        }
        
        // get the jwks url from the json response.
        self.jwksUrl = try container.decode(String.self, forKey: jwksUrlKey)
    }
}


/// Create a coding key which will represent the dynamic keyname provided by the user in the
/// `following` property of JWKSConfig.
///
public struct JWKSDocumentCodingKey: CodingKey {
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int? { return nil }
    
    public init?(intValue: Int) { return nil }
}

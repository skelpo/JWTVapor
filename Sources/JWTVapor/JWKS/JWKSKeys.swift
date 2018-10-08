import Foundation
import Vapor

public struct JWKSKeys: Content {
    let keys: [JWKSKey]
}

public struct JWKSKey: Content {
    let kty: String
    let use: String
    let kid: String
    let x5t: String
    let n: String
    let e: String
    let d: String?
    let issuer: String?
    let x5c: [String]
}

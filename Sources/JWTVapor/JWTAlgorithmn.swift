//
//  File.swift
//  
//
//  Created by Ralph Küpper on 12/10/19.
//

import Vapor


public enum JWTAlgorithm {
    case rsa(DigestAlgorithm = .sha256)
    case hmac(DigestAlgorithm = .sha256)
    case cert(DigestAlgorithm = .sha256)
    case custom((JWTHeader?, String, String?) -> JWTService)
}

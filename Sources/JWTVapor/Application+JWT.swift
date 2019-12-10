//
//  File.swift
//  
//
//  Created by Ralph Küpper on 12/10/19.
//

import Vapor
@_exported import JWTKit

class JWTConfig {
    var algorithm: JWTAlgorithm
    var header: JWTHeader?
    var secretVar: String
    var publicVar: String
    
    public init(algorithm: JWTAlgorithm, header: JWTHeader? = nil, secretVar: String? = nil, publicVar: String? = nil) {
        self.algorithm = algorithm
        self.header = header
        self.secretVar = secretVar ?? "JWT_SECRET"
        self.publicVar = publicVar ?? "JWT_PUBLIC"
    }
}

extension Application {
    
    private struct JWTServiceKey: StorageKey {
        typealias Value = JWTService
    }
    
    private struct JWTConfigKey: StorageKey {
        typealias Value = JWTConfig
    }

    var jwtConfig: JWTConfig {
        if let existing = self.storage[JWTConfigKey.self] {
            return existing
        } else {
            let config = JWTConfig(algorithm: .rsa(.sha256))
            self.storage[JWTConfigKey.self] = config
            return config
        }
    }
    
    
    var jwtService: JWTService {
        if let existing = self.storage[JWTServiceKey.self] {
            return existing
        } else {
            var new:JWTService
            guard let publicKey = Environment.get(self.jwtConfig.publicVar) else {
                print("No value was found at the given public key environmen '\(self.jwtConfig.publicVar)'")
                exit(0)
            }
            switch self.jwtConfig.algorithm {
            case let .rsa(alorithm): new = RSAService(n: publicKey, e: "AQAB", d: Environment.get(self.jwtConfig.secretVar), header: self.jwtConfig.header, algorithm: alorithm)
            case let .hmac(alorithm): new = HMACService(key: publicKey, header: self.jwtConfig.header, algorithm: alorithm)
            case let .cert(alorithm): new = CertService(certificate: Data(publicKey.utf8), header: self.jwtConfig.header, algorithm: alorithm)
            case let .custom(closure): new = closure(self.jwtConfig.header, publicKey, Environment.get(self.jwtConfig.secretVar))
            }
   
            self.storage[JWTServiceKey.self] = new
            return new
        }
    }

    

}



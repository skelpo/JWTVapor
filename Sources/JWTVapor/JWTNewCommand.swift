import ConsoleKit
import Foundation

public final class NewJWTCommand<Payload>: Command where Payload: JWTPayload {
    public struct Signature: CommandSignature {
        static var jsonHelp: String { """
        The payload for the generated token.
        If this flag is not use, the payload passed into the command's initializer is used.
        """ }

        @Option(name: "json", help: Signature.jsonHelp) var json: Data?

        public init() { }
    }
    
    public let help: String = "Creates a JWT token for debugging purposes."
    
    internal let payloadCreator: () -> Payload
    internal let signer: JWTService
    
    public init(payload: Payload, signer: JWTService) {
        self.payloadCreator = { payload }
        self.signer = signer
    }
    
    public init(signer: JWTService, _ handler: @escaping () -> Payload) {
        self.payloadCreator = handler
        self.signer = signer
    }
    
    public func run(using context: CommandContext, signature: Signature) throws {
        let payload: Payload =
            try signature.json.map { try JSONDecoder().decode(Payload.self, from: $0) } ??
            self.payloadCreator()
        
        let token = try signer.sign(payload)
        
        context.console.output("JWT Token: ", style: .info, newLine: false)
        context.console.output(token, style: .plain, newLine: true)
    }
}

extension Data: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(description.utf8)
    }
}

import Command
import Console

public final class NewJWTCommand<Payload>: Command where Payload: JWTPayload {
    public var arguments: [CommandArgument] = []
    
    public var options: [CommandOption] = [
        CommandOption.value(name: "json", help: [
            "The payload for the generated token",
            "If this flag is not use, the payload passed into the command's initializer is used"
        ])
    ]
    
    public var help: [String] = ["Creates a JWT token for debugging purposes."]
    
    internal let payloadCreator: () -> Payload
    
    public init(payload: Payload) {
        self.payloadCreator = { payload }
    }
    
    public init(_ handler: @escaping () -> Payload) {
        self.payloadCreator = handler
    }
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let signer = try context.container.make(JWTService.self)
        let payload: Payload
        if let json = context.options["json"]?.data(using: .utf8) {
            payload = try JSONDecoder().decode(Payload.self, from: json)
        } else {
            payload = self.payloadCreator()
        }
        
        let token = try signer.sign(payload)
        
        context.console.output("JWT Token: ", style: .info, newLine: false)
        context.console.output(token, style: .plain, newLine: true)
        
        return context.container.future()
    }
}

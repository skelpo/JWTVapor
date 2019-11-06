//import Foundation
//import Vapor
//
//struct JWKSMockClient: Client, ServiceType {
//    var container: Container
//    var requestString: String!
//    
//    init(container: Container) {
//        self.container = container
//    }
//    
//    func send(_ req: Request) -> EventLoopFuture<Response> {
//        var response: String = ""
//        
//        switch (req.http.url.absoluteString) {
//        case "https://mockurl.com":
//            response = JWKSResponseFixture.openIDDocumentResponse
//        case "https//:mock_jwks_uri.com":
//            response = JWKSResponseFixture.jwksResponse
//        default:
//            response = "{}"
//        }
//        
//        return Future.map(on: req) {
//            req.makeResponse(response, as: .json)
//        }
//    }
//    
//    public static var serviceSupports: [Any.Type] {
//        return [Client.self]
//    }
//    
//    static func makeService(for worker: Container) throws -> JWKSMockClient {
//        return JWKSMockClient(container: worker)
//    }
//}

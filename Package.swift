// swift-tools-version:4.0
import PackageDescription
let package = Package(
    name: "JWTProvider",
    products: [
        .library(name: "JWTProvider", targets: ["JWTProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc")
    ],
    targets: [
        .target(name: "JWTProvider", dependencies: ["Vapor", "Authentication", "JWT"]),
        .testTarget(name: "JWTProviderTests", dependencies: ["JWTProvider"]),
    ]
)

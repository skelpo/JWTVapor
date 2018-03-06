// swift-tools-version:4.0
import PackageDescription
let package = Package(
    name: "JWTProvider",
    products: [
        .library(name: "JWTProvider", targets: ["JWTProvider"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "JWTProvider", dependencies: []),
        .testTarget(name: "JWTProviderTests", dependencies: ["JWTProvider"]),
    ]
)
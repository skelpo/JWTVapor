// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "JWTVapor",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "JWTVapor", targets: ["JWTVapor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/jwt-kit.git", .revision("0c7e52ab75ddfabad539a4a2a2f9fc003e7700b7")),
//        .package(url: "https://github.com/vapor/auth.git", .branch("master"))
    ],
    targets: [
        .target(name: "JWTVapor", dependencies: ["Vapor", "JWTKit"]),
        .testTarget(name: "JWTVaporTests", dependencies: ["JWTVapor"]),
    ]
)

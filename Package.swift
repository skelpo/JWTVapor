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
        .package(url: "https://github.com/vapor/jwt-kit.git", .branch("master")),
//        .package(url: "https://github.com/vapor/auth.git", .branch("master"))
    ],
    targets: [
        .target(name: "JWTVapor", dependencies: ["Vapor", "JWTKit"]),
        .testTarget(name: "JWTVaporTests", dependencies: ["JWTVapor"]),
    ]
)

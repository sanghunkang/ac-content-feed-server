// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cfs",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.7.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura-OpenAPI.git", from: "1.3.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.1.11"),
        // .package(url: "")
    ],
    targets: [
        .target(name: "cfs", dependencies: [ .target(name: "Application"), "Kitura", "HeliumLogger"]),
        .target(name: "Application", dependencies: ["Kitura", "KituraOpenAPI", "MongoKitten"]),
        .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura" ])
    ]
)

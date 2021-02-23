// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Umbrella",
    platforms: [
        .macOS(.v11),.iOS(.v14),
    ],
    products: [
        .library(
            name: "Umbrella",
            targets: ["Umbrella"]
        ),
        .library(
            name: "TestUmbrella",
            targets: ["TestUmbrella"]
        ),
    ],
    dependencies: [
        .package(
            name: "ServerlessLogger",
            url: "https://github.com/jeffreybergier/JSBServerlessLogger.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "Umbrella",
            dependencies: ["ServerlessLogger"],
            path: "Sources/Umbrella"
        ),
        .target(
            name: "TestUmbrella",
            dependencies: [],
            path: "Sources/TestUmbrella"
        ),
        .testTarget(
            name: "UmbrellaTests",
            dependencies: ["Umbrella", "TestUmbrella"],
            path: "Tests/UmbrellaTests"
        ),
    ]
)

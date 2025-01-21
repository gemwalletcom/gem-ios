// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NFTService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NFTService",
            targets: ["NFTService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
    ],
    targets: [
        .target(
            name: "NFTService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NFTServiceTests",
            dependencies: ["NFTService"]
        ),
    ]
)

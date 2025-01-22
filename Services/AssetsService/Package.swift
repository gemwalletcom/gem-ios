// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AssetsService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AssetsService",
            targets: ["AssetsService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "ChainService", path: "../ChainService")
    ],
    targets: [
        .target(
            name: "AssetsService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "ChainService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AssetsServiceTests",
            dependencies: ["AssetsService"]
        ),
    ]
)

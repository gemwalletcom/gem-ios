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
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "NodeService", path: "../NodeService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "GemstonePrimitives", path: ".../GemstonePrimitives")
    ],
    targets: [
        .target(
            name: "AssetsService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "ChainService",
                "NodeService",
                "Preferences",
                "GemstonePrimitives"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AssetsServiceTests",
            dependencies: ["AssetsService"]
        ),
    ]
)

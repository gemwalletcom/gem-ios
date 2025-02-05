// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DiscoverAssetsService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DiscoverAssetsService",
            targets: ["DiscoverAssetsService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "GemAPI", path: "../GemAPI"),
    ],
    targets: [
        .target(
            name: "DiscoverAssetsService",
            dependencies: [
                "Primitives",
                "ChainService",
                "BalanceService",
                "GemAPI",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DiscoverAssetsServiceTests",
            dependencies: ["DiscoverAssetsService"]
        ),
    ]
)

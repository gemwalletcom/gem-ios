// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DiscoverAssetsService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "DiscoverAssetsService",
            targets: ["DiscoverAssetsService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
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
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "DiscoverAssetsService"
            ]
        ),
    ]
)

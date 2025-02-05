// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletsService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WalletsService",
            targets: ["WalletsService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "BannerService", path: "../BannerService"),
        .package(name: "PriceService", path: "../PriceService"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "AssetsService", path: "../AssetsService"),
        .package(name: "TransactionService", path: "../TransactionService"),
        .package(name: "DiscoverAssetsService", path: "../DiscoverAssetsService"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "WalletsService",
            dependencies: [
                "Primitives",
                "Keystore",
                "BannerService",
                "PriceService",
                "Preferences",
                "BalanceService",
                "AssetsService",
                "TransactionService",
                "DiscoverAssetsService",
                "ChainService",
                "GemstonePrimitives"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletsServiceTests",
            dependencies: ["WalletsService"]
        ),
    ]
)

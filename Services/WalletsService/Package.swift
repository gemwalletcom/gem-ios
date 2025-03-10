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
        .package(name: "Store", path: "../Store"),
        .package(name: "BannerService", path: "../BannerService"),
        .package(name: "PriceService", path: "../PriceService"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "AssetsService", path: "../AssetsService"),
        .package(name: "TransactionService", path: "../TransactionService"),
        .package(name: "DiscoverAssetsService", path: "../DiscoverAssetsService"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "WalletSessionService", path: "../WalletSessionService"),
    ],
    targets: [
        .target(
            name: "WalletsService",
            dependencies: [
                "Primitives",
                "Store",
                "BannerService",
                "PriceService",
                "Preferences",
                "BalanceService",
                "AssetsService",
                "TransactionService",
                "DiscoverAssetsService",
                "ChainService",
                "WalletSessionService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletsServiceTests",
            dependencies: ["WalletsService"]
        ),
    ]
)

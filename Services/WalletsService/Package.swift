// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletsService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WalletsService",
            targets: ["WalletsService"]
        ),
        .library(
            name: "WalletsServiceTestKit",
            targets: ["WalletsServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "BannerService", path: "../BannerService"),
        .package(name: "PriceService", path: "../PriceService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "AssetsService", path: "../AssetsService"),
        .package(name: "TransactionService", path: "../TransactionService"),
        .package(name: "DiscoverAssetsService", path: "../DiscoverAssetsService"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "WalletSessionService", path: "../WalletSessionService"),
        .package(name: "DeviceService", path: "../DeviceService"),
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
                "WalletSessionService",
                "DeviceService"
            ],
            path: "Sources"
        ),
        .target(
            name: "WalletsServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "AssetsServiceTestKit", package: "AssetsService"),
                .product(name: "BalanceServiceTestKit", package: "BalanceService"),
                .product(name: "PriceServiceTestKit", package: "PriceService"),
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                .product(name: "TransactionServiceTestKit", package: "TransactionService"),
                .product(name: "BannerServiceTestKit", package: "BannerService"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "DeviceServiceTestKit", package: "DeviceService"),
                "WalletsService"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "WalletsServiceTests",
            dependencies: ["WalletsService"]
        ),
    ]
)

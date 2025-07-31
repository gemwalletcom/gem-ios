// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SystemServices",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "NotificationService", targets: ["NotificationService"]),
        .library(name: "NotificationServiceTestKit", targets: ["NotificationServiceTestKit"]),
        .library(name: "DeviceService", targets: ["DeviceService"]),
        .library(name: "DeviceServiceTestKit", targets: ["DeviceServiceTestKit"]),
        .library(name: "BannerService", targets: ["BannerService"]),
        .library(name: "BannerServiceTestKit", targets: ["BannerServiceTestKit"]),
        .library(name: "AppService", targets: ["AppService"]),
        .library(name: "ImageGalleryService", targets: ["ImageGalleryService"]),
        .library(name: "WalletService", targets: ["WalletService"]),
        .library(name: "WalletServiceTestKit", targets: ["WalletServiceTestKit"]),
        .library(name: "WalletsService", targets: ["WalletsService"]),
        .library(name: "WalletsServiceTestKit", targets: ["WalletsServiceTestKit"]),
        .library(name: "NativeProviderService", targets: ["NativeProviderService"]),
        .library(name: "WalletSessionService", targets: ["WalletSessionService"]),
        .library(name: "WalletSessionServiceTestKit", targets: ["WalletSessionServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "ChainServices", path: "../ChainServices"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "FeatureServices", path: "../FeatureServices"),
    ],
    targets: [
        .target(
            name: "NotificationService",
            dependencies: [
                "Preferences"
            ],
            path: "NotificationService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "NotificationServiceTestKit",
            dependencies: [
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "NotificationService"
            ],
            path: "NotificationService/TestKit"
        ),
        .target(
            name: "DeviceService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences",
                "GemAPI",
            ],
            path: "DeviceService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "DeviceServiceTestKit",
            dependencies: [
                "DeviceService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "DeviceService/TestKit"
        ),
        .target(
            name: "BannerService",
            dependencies: [
                "Primitives",
                "Store",
                "NotificationService",
                "Preferences"
            ],
            path: "BannerService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "BannerServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                "NotificationServiceTestKit",
                "BannerService"
            ],
            path: "BannerService/TestKit"
        ),
        .target(
            name: "AppService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                .product(name: "NodeService", package: "ChainServices"),
                "Preferences",
                "BannerService",
                "DeviceService",
                .product(name: "SwapService", package: "FeatureServices"),
                .product(name: "AssetsService", package: "FeatureServices"),
                "WalletService"
            ],
            path: "AppService",
            exclude: ["Tests"]
        ),
        .target(
            name: "ImageGalleryService",
            dependencies: [],
            path: "ImageGalleryService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "WalletService",
            dependencies: [
                "Primitives",
                "Keystore",
                "Store",
                "Preferences",
                .product(name: "AvatarService", package: "FeatureServices"),
                "WalletSessionService"
            ],
            path: "WalletService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "WalletServiceTestKit",
            dependencies: [
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
                "WalletService"
            ],
            path: "WalletService/TestKit"
        ),
        .target(
            name: "WalletsService",
            dependencies: [
                "Primitives",
                "Store",
                "BannerService",
                .product(name: "PriceService", package: "FeatureServices"),
                "Preferences",
                .product(name: "BalanceService", package: "FeatureServices"),
                .product(name: "AssetsService", package: "FeatureServices"),
                .product(name: "TransactionService", package: "FeatureServices"),
                .product(name: "DiscoverAssetsService", package: "FeatureServices"),
                .product(name: "ChainService", package: "ChainServices"),
                "WalletSessionService",
                "DeviceService"
            ],
            path: "WalletsService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "WalletsServiceTestKit",
            dependencies: [
                "DeviceServiceTestKit",
                "BannerServiceTestKit",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "BalanceServiceTestKit", package: "FeatureServices"),
                .product(name: "TransactionServiceTestKit", package: "FeatureServices"),
                "WalletsService"
            ],
            path: "WalletsService/TestKit"
        ),
        .target(
            name: "NativeProviderService",
            dependencies: [
                "Primitives",
                .product(name: "ChainService", package: "ChainServices"),
            ],
            path: "NativeProviderService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "WalletSessionService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences"
            ],
            path: "WalletSessionService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "WalletSessionServiceTestKit",
            dependencies: [
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "WalletSessionService/TestKit"
        ),
    ]
)

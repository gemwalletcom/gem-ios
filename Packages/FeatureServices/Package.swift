// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FeatureServices",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "PerpetualService", targets: ["PerpetualService"]),
        .library(name: "BalanceService", targets: ["BalanceService"]),
        .library(name: "BalanceServiceTestKit", targets: ["BalanceServiceTestKit"]),
        .library(name: "NFTService", targets: ["NFTService"]),
        .library(name: "NFTServiceTestKit", targets: ["NFTServiceTestKit"]),
        .library(name: "AvatarService", targets: ["AvatarService"]),
        .library(name: "PriceService", targets: ["PriceService"]),
        .library(name: "PriceServiceTestKit", targets: ["PriceServiceTestKit"]),
        .library(name: "PriceAlertService", targets: ["PriceAlertService"]),
        .library(name: "PriceAlertServiceTestKit", targets: ["PriceAlertServiceTestKit"]),
        .library(name: "TransactionService", targets: ["TransactionService"]),
        .library(name: "TransactionServiceTestKit", targets: ["TransactionServiceTestKit"]),
        .library(name: "TransactionsService", targets: ["TransactionsService"]),
        .library(name: "TransactionsServiceTestKit", targets: ["TransactionsServiceTestKit"]),
        .library(name: "DiscoverAssetsService", targets: ["DiscoverAssetsService"]),
        .library(name: "SwapService", targets: ["SwapService"]),
        .library(name: "SwapServiceTestKit", targets: ["SwapServiceTestKit"]),
        .library(name: "AssetsService", targets: ["AssetsService"]),
        .library(name: "AssetsServiceTestKit", targets: ["AssetsServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Blockchain", path: "../Blockchain"),
        .package(name: "ChainServices", path: "../ChainServices"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "SystemServices", path: "../SystemServices"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "Signer", path: "../Signer"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "Formatters", path: "../Formatters"),
    ],
    targets: [
        .target(
            name: "PerpetualService",
            dependencies: [
                "Primitives",
                "Store",
                "Blockchain",
                "Formatters",
                .product(name: "ChainService", package: "ChainServices"),
            ],
            path: "PerpetualService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "BalanceService",
            dependencies: [
                "Primitives",
                "Store",
                .product(name: "ChainService", package: "ChainServices"),
                "AssetsService"
            ],
            path: "BalanceService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "BalanceServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                "AssetsServiceTestKit",
                "BalanceService",
                "Primitives"
            ],
            path: "BalanceService/TestKit"
        ),
        .target(
            name: "NFTService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                .product(name: "DeviceService", package: "SystemServices"),
            ],
            path: "NFTService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "NFTServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "NFTService",
                .product(name: "DeviceServiceTestKit", package: "SystemServices"),
            ],
            path: "NFTService/TestKit"
        ),
        .target(
            name: "AvatarService",
            dependencies: [
                "Primitives",
                "Store"
            ],
            path: "AvatarService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "PriceService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "Preferences"
            ],
            path: "PriceService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "PriceServiceTestKit",
            dependencies: [
                "Primitives",
                "PriceService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
            ],
            path: "PriceService/TestKit"
        ),
        .target(
            name: "PriceAlertService",
            dependencies: [
                "Primitives",
                "Store",
                .product(name: "NotificationService", package: "SystemServices"),
                .product(name: "DeviceService", package: "SystemServices"),
                "GemAPI",
                "PriceService",
                "Preferences"
            ],
            path: "PriceAlertService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "PriceAlertServiceTestKit",
            dependencies: [
                "PriceAlertService",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "DeviceServiceTestKit", package: "SystemServices"),
                "PriceServiceTestKit"
            ],
            path: "PriceAlertService/TestKit"
        ),
        .target(
            name: "TransactionService",
            dependencies: [
                "Primitives",
                "Store",
                "Blockchain",
                .product(name: "ChainService", package: "ChainServices"),
                .product(name: "StakeService", package: "ChainServices"),
                "BalanceService",
                "NFTService",
                "GemstonePrimitives"
            ],
            path: "TransactionService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "TransactionServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "StakeServiceTestKit", package: "ChainServices"),
                "NFTServiceTestKit",
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                "BalanceServiceTestKit",
                "TransactionService"
            ],
            path: "TransactionService/TestKit"
        ),
        .target(
            name: "TransactionsService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Store",
                "Preferences",
                "AssetsService",
                .product(name: "DeviceService", package: "SystemServices"),
            ],
            path: "TransactionsService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "TransactionsServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                "AssetsServiceTestKit",
                "TransactionsService",
                .product(name: "DeviceServiceTestKit", package: "SystemServices"),
            ],
            path: "TransactionsService/TestKit"
        ),
        .target(
            name: "DiscoverAssetsService",
            dependencies: [
                "Primitives",
                .product(name: "ChainService", package: "ChainServices"),
                "BalanceService",
                "GemAPI",
            ],
            path: "DiscoverAssetsService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "SwapService",
            dependencies: [
                "Gemstone",
                "GemstonePrimitives",
                "Primitives",
                .product(name: "ChainService", package: "ChainServices"),
                "Signer",
                "Keystore",
                .product(name: "NativeProviderService", package: "SystemServices"),
            ],
            path: "SwapService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "SwapServiceTestKit",
            dependencies: [
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                "SwapService",
                "Gemstone"
            ],
            path: "SwapService/TestKit"
        ),
        .target(
            name: "AssetsService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                .product(name: "ChainService", package: "ChainServices"),
                "Preferences",
                "GemstonePrimitives"
            ],
            path: "AssetsService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "AssetsServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                "AssetsService",
                "Primitives",
                "Preferences",
                "GemstonePrimitives"
            ],
            path: "AssetsService/TestKit"
        ),
    ]
)

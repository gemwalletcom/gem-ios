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
        .library(name: "PerpetualServiceTestKit", targets: ["PerpetualServiceTestKit"]),
        .library(name: "BalanceService", targets: ["BalanceService"]),
        .library(name: "BalanceServiceTestKit", targets: ["BalanceServiceTestKit"]),
        .library(name: "BannerService", targets: ["BannerService"]),
        .library(name: "BannerServiceTestKit", targets: ["BannerServiceTestKit"]),
        .library(name: "NFTService", targets: ["NFTService"]),
        .library(name: "NFTServiceTestKit", targets: ["NFTServiceTestKit"]),
        .library(name: "AvatarService", targets: ["AvatarService"]),
        .library(name: "PriceService", targets: ["PriceService"]),
        .library(name: "PriceServiceTestKit", targets: ["PriceServiceTestKit"]),
        .library(name: "PriceAlertService", targets: ["PriceAlertService"]),
        .library(name: "PriceAlertServiceTestKit", targets: ["PriceAlertServiceTestKit"]),
        .library(name: "TransactionStateService", targets: ["TransactionStateService"]),
        .library(name: "TransactionStateServiceTestKit", targets: ["TransactionStateServiceTestKit"]),
        .library(name: "TransactionsService", targets: ["TransactionsService"]),
        .library(name: "TransactionsServiceTestKit", targets: ["TransactionsServiceTestKit"]),
        .library(name: "DiscoverAssetsService", targets: ["DiscoverAssetsService"]),
        .library(name: "SwapService", targets: ["SwapService"]),
        .library(name: "SwapServiceTestKit", targets: ["SwapServiceTestKit"]),
        .library(name: "AssetsService", targets: ["AssetsService"]),
        .library(name: "AssetsServiceTestKit", targets: ["AssetsServiceTestKit"]),
        .library(name: "WalletsService", targets: ["WalletsService"]),
        .library(name: "WalletsServiceTestKit", targets: ["WalletsServiceTestKit"]),
        .library(name: "WalletSessionService", targets: ["WalletSessionService"]),
        .library(name: "WalletSessionServiceTestKit", targets: ["WalletSessionServiceTestKit"]),
        .library(name: "WalletService", targets: ["WalletService"]),
        .library(name: "WalletServiceTestKit", targets: ["WalletServiceTestKit"]),
        .library(name: "AppService", targets: ["AppService"]),
        .library(name: "AppServiceTestKit", targets: ["AppServiceTestKit"]),
        .library(name: "DeviceService", targets: ["DeviceService"]),
        .library(name: "DeviceServiceTestKit", targets: ["DeviceServiceTestKit"]),
        .library(name: "NotificationService", targets: ["NotificationService"]),
        .library(name: "NotificationServiceTestKit", targets: ["NotificationServiceTestKit"]),
        .library(name: "AddressNameService", targets: ["AddressNameService"]),
        .library(name: "AddressNameServiceTestKit", targets: ["AddressNameServiceTestKit"]),
        .library(name: "NativeProviderService", targets: ["NativeProviderService"]),
        .library(name: "ActivityService", targets: ["ActivityService"]),
        .library(name: "ActivityServiceTestKit", targets: ["ActivityServiceTestKit"]),
        .library(name: "RewardsService", targets: ["RewardsService"]),
        .library(name: "RewardsServiceTestKit", targets: ["RewardsServiceTestKit"]),
        .library(name: "AuthService", targets: ["AuthService"]),
        .library(name: "AuthServiceTestKit", targets: ["AuthServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Blockchain", path: "../Blockchain"),
        .package(name: "ChainServices", path: "../ChainServices"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "Signer", path: "../Signer"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "Formatters", path: "../Formatters"),
        .package(name: "SwiftHTTPClient", path: "../SwiftHTTPClient"),
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
            name: "PerpetualServiceTestKit",
            dependencies: [
                "PerpetualService",
                "Primitives",
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "PerpetualService/TestKit"
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
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "AssetsServiceTestKit",
                "BalanceService",
                "Primitives"
            ],
            path: "BalanceService/TestKit"
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
            exclude: ["TestKit", "Tests"]
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
            name: "NFTService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "DeviceService",
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
                "DeviceServiceTestKit",
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
                "Preferences",
                .product(name: "WebSocketClient", package: "SwiftHTTPClient")
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
                "NotificationService",
                "DeviceService",
                "GemAPI",
                "PriceService",
                "Preferences"
            ],
            path: "PriceAlertService",
            exclude: ["TestKit", "Tests"]
        ),
        .target(
            name: "PriceAlertServiceTestKit",
            dependencies: [
                "PriceAlertService",
                .product(name: "StoreTestKit", package: "Store"),
                "DeviceServiceTestKit",
                "PriceServiceTestKit",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "PreferencesTestKit", package: "Preferences")
            ],
            path: "PriceAlertService/TestKit"
        ),
        .target(
            name: "TransactionStateService",
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
            path: "TransactionStateService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "TransactionStateServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "StakeServiceTestKit", package: "ChainServices"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "NFTServiceTestKit",
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                "BalanceServiceTestKit",
                "TransactionStateService"
            ],
            path: "TransactionStateService/TestKit"
        ),
        .target(
            name: "TransactionsService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Store",
                "Preferences",
                "AssetsService",
                "DeviceService",
            ],
            path: "TransactionsService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "TransactionsServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "AssetsServiceTestKit",
                "TransactionsService",
                "DeviceServiceTestKit",
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
                "NativeProviderService",
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
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "AssetsService",
                "Primitives",
                "GemstonePrimitives"
            ],
            path: "AssetsService/TestKit"
        ),
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
                "TransactionStateService",
                "DiscoverAssetsService",
                .product(name: "ChainService", package: "ChainServices"),
                "WalletSessionService",
                "DeviceService"
            ],
            path: "WalletsService",
            exclude: ["TestKit", "Tests"]
        ),
        .target(
            name: "WalletsServiceTestKit",
            dependencies: [
                "DeviceServiceTestKit",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "PriceServiceTestKit",
                "BalanceServiceTestKit",
                "WalletSessionService",
                "WalletSessionServiceTestKit",
                "WalletsService"
            ],
            path: "WalletsService/TestKit"
        ),
        .target(
            name: "WalletSessionService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences"
            ],
            path: "WalletSessionService",
            exclude: ["TestKit", "Tests"]
        ),
        .target(
            name: "WalletSessionServiceTestKit",
            dependencies: [
                "WalletSessionService",
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "WalletSessionService/TestKit"
        ),
        .target(
            name: "WalletService",
            dependencies: [
                "Primitives",
                "Keystore",
                "Store",
                "Preferences",
                "AvatarService",
                "WalletSessionService"
            ],
            path: "WalletService",
            exclude: ["TestKit", "Tests"]
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
            name: "AppService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                .product(name: "NodeService", package: "ChainServices"),
                .product(name: "ChainService", package: "ChainServices"),
                "GemstonePrimitives",
                "Preferences",
                "BannerService",
                "DeviceService",
                "AssetsService",
                "WalletService",
                "NotificationService"
            ],
            path: "AppService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "AppServiceTestKit",
            dependencies: [
                "AppService",
                "Primitives",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "BannerServiceTestKit",
                .product(name: "NodeServiceTestKit", package: "ChainServices"),
                "DeviceServiceTestKit",
                "AssetsServiceTestKit",
                .product(name: "PreferencesTestKit", package: "Preferences"),
            ],
            path: "AppService/TestKit"
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
                "NotificationService",
                .product(name: "PreferencesTestKit", package: "Preferences")
            ],
            path: "NotificationService/TestKit"
        ),
        .target(
            name: "AddressNameService",
            dependencies: [
                "Primitives",
                "Store"
            ],
            path: "AddressNameService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "AddressNameServiceTestKit",
            dependencies: [
                "AddressNameService",
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "AddressNameService/TestKit"
        ),
        .target(
            name: "NativeProviderService",
            dependencies: [
                "Primitives",
                "Gemstone"
            ],
            path: "NativeProviderService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "ActivityService",
            dependencies: [
                "Primitives",
                "Store"
            ],
            path: "ActivityService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "ActivityServiceTestKit",
            dependencies: [
                "ActivityService",
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "ActivityService/TestKit"
        ),
        .target(
            name: "RewardsService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "AuthService",
            ],
            path: "RewardsService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "RewardsServiceTestKit",
            dependencies: [
                "RewardsService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
            ],
            path: "RewardsService/TestKit"
        ),
        .target(
            name: "AuthService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Keystore",
                "Gemstone",
                "GemstonePrimitives",
                "Preferences",
            ],
            path: "AuthService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "AuthServiceTestKit",
            dependencies: [
                "AuthService",
            ],
            path: "AuthService/TestKit"
        ),
        .testTarget(
            name: "PriceAlertServiceTests",
            dependencies: [
                "PriceAlertService",
                "PriceAlertServiceTestKit",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "DeviceServiceTestKit",
                "PriceServiceTestKit",
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ],
            path: "PriceAlertService/Tests"
        ),
        .testTarget(
            name: "BannerServiceTests",
            dependencies: [
                "BannerService",
                "BannerServiceTestKit",
                .product(name: "StoreTestKit", package: "Store"),
                "NotificationServiceTestKit",
                "Primitives"
            ],
            path: "BannerService/Tests"
        ),
        .testTarget(
            name: "WalletSessionServiceTests",
            dependencies: [
                "WalletSessionService",
                "WalletSessionServiceTestKit",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ],
            path: "WalletSessionService/Tests"
        ),
        .testTarget(
            name: "WalletsServiceTests",
            dependencies: [
                "WalletsService",
                "WalletsServiceTestKit",
                "WalletSessionService",
                .product(name: "StoreTestKit", package: "Store"),
                "BalanceServiceTestKit",
                "PriceServiceTestKit",
                "AssetsServiceTestKit",
                "DeviceServiceTestKit",
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ],
            path: "WalletsService/Tests"
        ),
        .testTarget(
            name: "WalletServiceTests",
            dependencies: [
                "WalletService",
                "WalletServiceTestKit",
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ],
            path: "WalletService/Tests"
        ),
        .testTarget(
            name: "AppServiceTests",
            dependencies: [
                "AppService",
                "AppServiceTestKit",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "AppService/Tests"
        ),
    ]
)

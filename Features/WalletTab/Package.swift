// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletTab",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WalletTab",
            targets: ["WalletTab"]
        ),
        .library(
            name: "WalletTabTestKit",
            targets: ["WalletTabTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "InfoSheet", path: "../InfoSheet"),

        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "Perpetuals", path: "../Perpetuals"),
    ],
    targets: [
        .target(
            name: "WalletTab",
            dependencies: [
                "Primitives",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "InfoSheet",
                "Store",
                "Preferences",
                .product(name: "WalletsService", package: "FeatureServices"),
                .product(name: "BannerService", package: "SystemServices"),
                .product(name: "WalletService", package: "SystemServices"),
                "Perpetuals"
            ],
            path: "Sources"
        ),
        .target(
            name: "WalletTabTestKit",
            dependencies: [
                .product(name: "WalletsServiceTestKit", package: "FeatureServices"),
                .product(name: "BannerServiceTestKit", package: "SystemServices"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletServiceTestKit", package: "SystemServices"),
                "WalletTab"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "WalletTabTests",
            dependencies: [
                .product(name: "WalletsServiceTestKit", package: "FeatureServices"),
                .product(name: "BannerServiceTestKit", package: "SystemServices"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletServiceTestKit", package: "SystemServices"),
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                .product(name: "PriceServiceTestKit", package: "FeatureServices"),
                .product(name: "AssetsServiceTestKit", package: "FeatureServices"),
                .product(name: "BalanceServiceTestKit", package: "FeatureServices"),
                .product(name: "TransactionServiceTestKit", package: "FeatureServices"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store"),
                "WalletTab"
            ]
        ),
    ]
)

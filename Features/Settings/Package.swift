// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Settings",
            targets: ["Settings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),

        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "Support", path: "../Support")
    ],
    targets: [
        .target(
            name: "Settings",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                "Preferences",
                "GemstonePrimitives",
                "Gemstone",
                "Keystore",
                .product(name: "WalletsService", package: "FeatureServices"),
                .product(name: "BannerService", package: "FeatureServices"),
                .product(name: "StakeService", package: "ChainServices"),
                .product(name: "AssetsService", package: "FeatureServices"),
                .product(name: "TransactionsService", package: "FeatureServices"),
                .product(name: "NotificationService", package: "FeatureServices"),
                .product(name: "DeviceService", package: "FeatureServices"),
                .product(name: "PriceService", package: "FeatureServices"),
                .product(name: "AppService", package: "FeatureServices"),
                .product(name: "PerpetualService", package: "FeatureServices"),
                .product(name: "RewardsService", package: "FeatureServices"),
                "Formatters",
                .product(name: "ChainService", package: "ChainServices"),
                .product(name: "NodeService", package: "ChainServices"),
                .product(name: "ExplorerService", package: "ChainServices"),
                "QRScanner",
                "Support"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]),
        .testTarget(
            name: "CurrencyTests",
            dependencies: [
                "Settings",
                "Primitives",
                .product(name: "PriceServiceTestKit", package: "FeatureServices")
            ]),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Swap",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "Swap",
            targets: ["Swap"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
    ],
    targets: [
        .target(
            name: "Swap",
            dependencies: [
                "Primitives",
                "Formatters",
                "Components",
                "GemstonePrimitives",
                "Gemstone",
                "Localization",
                .product(name: "SwapService", package: "FeatureServices"),
                "Store",
                "Preferences",
                .product(name: "WalletsService", package: "FeatureServices"),
                "PrimitivesComponents",
                "InfoSheet",
                "Keystore",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SwapTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletsServiceTestKit", package: "FeatureServices"),
                .product(name: "SwapServiceTestKit", package: "FeatureServices"),
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "PriceServiceTestKit", package: "FeatureServices"),
                .product(name: "AssetsServiceTestKit", package: "FeatureServices"),
                .product(name: "BalanceServiceTestKit", package: "FeatureServices"),
                .product(name: "TransactionServiceTestKit", package: "FeatureServices"),
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store"),
                "Swap"
            ]
        )
    ]
)

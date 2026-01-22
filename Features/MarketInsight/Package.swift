// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MarketInsight",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "MarketInsight",
            targets: ["MarketInsight"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
    ],
    targets: [
        .target(
            name: "MarketInsight",
            dependencies: [
                "Primitives",
                "Formatters",
                "Localization",
                "Gemstone",
                "Store",
                .product(name: "ExplorerService", package: "ChainServices"),
                "PrimitivesComponents",
                "Components",
                "Preferences",
                .product(name: "PriceService", package: "FeatureServices"),
                .product(name: "PriceAlertService", package: "FeatureServices"),
                .product(name: "AssetsService", package: "FeatureServices"),
                "InfoSheet"
            ],
            path: "Sources"
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MarketInsight",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
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
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
        .package(name: "AssetsService", path: "../../Services/AssetsService"),
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
                "ExplorerService",
                "PrimitivesComponents",
                "Components",
                "Preferences",
                "PriceService",
                "AssetsService"
            ],
            path: "Sources"
        ),
    ]
)

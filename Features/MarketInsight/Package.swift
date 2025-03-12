// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MarketInsight",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "MarketInsight",
            targets: ["MarketInsight"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "Store", path: "../Store"),
        .package(name: "ExplorerService", path: "../ExplorerService"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "PriceService", path: "../PriceService"),
        .package(name: "AssetsService", path: "../AssetsService")
    ],
    targets: [
        .target(
            name: "MarketInsight",
            dependencies: [
                "Primitives",
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

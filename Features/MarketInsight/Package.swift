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
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "ExplorerService", path: "../ExplorerService"),

    ],
    targets: [
        .target(
            name: "MarketInsight",
            dependencies: [
                "Primitives",
                "Localization",
                "Gemstone",
                "GemstonePrimitives",
                "Store",
                "ExplorerService"
            ],
            path: "Sources"
        ),
    ]
)

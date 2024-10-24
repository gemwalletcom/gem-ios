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
    ],
    targets: [
        .target(
            name: "MarketInsight",
            dependencies: [
                "Primitives",
                "Localization",
            ],
            path: "Sources"
        ),
    ]
)

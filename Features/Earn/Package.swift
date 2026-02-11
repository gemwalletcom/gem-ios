// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Earn",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Earn",
            targets: ["Earn"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "Style", path: "../../Packages/Style"),
    ],
    targets: [
        .target(
            name: "Earn",
            dependencies: [
                "Primitives",
                "Components",
                "Localization",
                "Store",
                "PrimitivesComponents",
                "Formatters",
                .product(name: "EarnService", package: "FeatureServices"),
                "Style",
            ],
            path: "Sources"
        ),
    ]
)

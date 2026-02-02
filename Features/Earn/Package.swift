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
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
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
                "GemstonePrimitives",
                "Gemstone",
                "Localization",
                .product(name: "StakeService", package: "ChainServices"),
                .product(name: "ExplorerService", package: "ChainServices"),
                .product(name: "NodeService", package: "ChainServices"),
                "Preferences",
                "Store",
                "InfoSheet",
                "PrimitivesComponents",
                "Formatters",
                .product(name: "YieldService", package: "FeatureServices"),
                "Style",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "EarnTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StakeServiceTestKit", package: "ChainServices"),
                .product(name: "YieldServiceTestKit", package: "FeatureServices"),
                "Earn"
            ],
            path: "Tests"
        ),
    ]
)

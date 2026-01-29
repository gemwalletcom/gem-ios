// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Yield",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Yield",
            targets: ["Yield"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Style", path: "../../Packages/Style"),
    ],
    targets: [
        .target(
            name: "Yield",
            dependencies: [
                "Primitives",
                "Components",
                "Gemstone",
                "Localization",
                .product(name: "YieldService", package: "FeatureServices"),
                "Store",
                "PrimitivesComponents",
                "Formatters",
                "Style",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "YieldTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "YieldServiceTestKit", package: "FeatureServices"),
                "Yield"
            ],
            path: "Tests"
        ),
    ]
)

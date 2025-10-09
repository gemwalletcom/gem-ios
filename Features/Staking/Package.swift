// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Staking",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Staking",
            targets: ["Staking"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Formatters", path: "../../Packages/Formatters")

    ],
    targets: [
        .target(
            name: "Staking",
            dependencies: [
                "Primitives",
                "Components",
                "GemstonePrimitives",
                "Localization",
                .product(name: "StakeService", package: "ChainServices"),
                .product(name: "ExplorerService", package: "ChainServices"),
                "Preferences",
                "Store",
                "InfoSheet",
                "PrimitivesComponents",
                "Formatters"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "StakingTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StakeServiceTestKit", package: "ChainServices"),
                "Staking"
            ],
            path: "Tests"
        ),
    ]
)

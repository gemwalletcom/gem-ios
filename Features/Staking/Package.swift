// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Staking",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
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
        .package(name: "StakeService", path: "../../Services/StakeService"),
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),

    ],
    targets: [
        .target(
            name: "Staking",
            dependencies: [
                "Primitives",
                "Components",
                "GemstonePrimitives",
                "Localization",
                "StakeService",
                "ExplorerService",
                "Preferences",
                "Store",
                "InfoSheet",
                "PrimitivesComponents"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "StakingTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StakeServiceTestKit", package: "StakeService"),
                "Staking"
            ],
            path: "Tests"
        ),
    ]
)

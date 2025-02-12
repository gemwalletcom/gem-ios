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
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "StakeService", path: "../StakeService"),
        .package(name: "ExplorerService", path: "../ExplorerService"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "Store", path: "../Store"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),

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
                "Staking",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        ),
    ]
)

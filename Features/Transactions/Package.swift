// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transactions",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Transactions",
            targets: ["Transactions"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
    ],
    targets: [
        .target(
            name: "Transactions",
            dependencies: [
                "Primitives",
                "Localization",
                "Store",
                "Style",
                "Components",
                "PrimitivesComponents",
                .product(name: "ExplorerService", package: "ChainServices"),
                .product(name: "TransactionsService", package: "FeatureServices"),
                .product(name: "WalletService", package: "SystemServices"),
                "Preferences",
                "InfoSheet"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransactionsTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "Transactions",
                "PrimitivesComponents"
            ]
        ),
    ]
)

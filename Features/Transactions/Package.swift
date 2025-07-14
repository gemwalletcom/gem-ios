// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transactions",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
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
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "TransactionsService", path: "../../Services/TransactionsService"),
        .package(name: "WalletService", path: "../../Services/WalletService"),
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
                "ExplorerService",
                "TransactionsService",
                "WalletService",
                "Preferences",
                "InfoSheet"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransactionsTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "Transactions",
                "PrimitivesComponents"
            ]
        ),
    ]
)

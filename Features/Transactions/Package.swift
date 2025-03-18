// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transactions",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Transactions",
            targets: ["Transactions"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Components", path: "../Components"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "ExplorerService", path: "../ExplorerService"),
        .package(name: "TransactionsService", path: "../TransactionsService"),
        .package(name: "ManageWalletService", path: "../ManageWalletService"),
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
                "ManageWalletService",
                "Preferences",
                "InfoSheet"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransactionsTests",
            dependencies: ["Transactions"]
        ),
    ]
)

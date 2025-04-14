// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TransactionsService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TransactionsService",
            targets: ["TransactionsService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "AssetsService", path: "../AssetsService"),
    ],
    targets: [
        .target(
            name: "TransactionsService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Store",
                "Preferences",
                "AssetsService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransactionsServiceTests",
            dependencies: ["TransactionsService"]
        ),
    ]
)

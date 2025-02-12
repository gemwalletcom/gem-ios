// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TransactionService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TransactionService",
            targets: ["TransactionService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Blockchain", path: "../Blockchain"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "StakeService", path: "../StakeService"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "NFTService", path: "../NFTService"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "TransactionService",
            dependencies: [
                "Primitives",
                "Store",
                "Blockchain",
                "ChainService",
                "StakeService",
                "BalanceService",
                "NFTService",
                "GemstonePrimitives"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransactionServiceTests",
            dependencies: ["TransactionService"]
        ),
    ]
)

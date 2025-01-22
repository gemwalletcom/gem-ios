// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BalanceService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BalanceService",
            targets: ["BalanceService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "ChainService", path: "../ChainService"),
    ],
    targets: [
        .target(
            name: "BalanceService",
            dependencies: [
                "Primitives",
                "Store",
                "ChainService",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "BalanceServiceTests",
            dependencies: ["BalanceService"]
        ),
    ]
)

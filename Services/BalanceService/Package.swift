// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BalanceService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "BalanceService",
            targets: ["BalanceService"]
        ),
        .library(
            name: "BalanceServiceTestKit",
            targets: ["BalanceServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "AssetsService", path: "../AssetsService")
    ],
    targets: [
        .target(
            name: "BalanceService",
            dependencies: [
                "Primitives",
                "Store",
                "ChainService",
                "AssetsService"
            ],
            path: "Sources"
        ),
        .target(
            name: "BalanceServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                .product(name: "AssetsServiceTestKit", package: "AssetsService"),
                "BalanceService",
                "Primitives"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "BalanceServiceTests",
            dependencies: ["BalanceService"]
        ),
    ]
)

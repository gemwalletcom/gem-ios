// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TransactionService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "TransactionService",
            targets: ["TransactionService"]
        ),
        .library(
            name: "TransactionServiceTestKit",
            targets: ["TransactionServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "StakeService", path: "../StakeService"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "NFTService", path: "../NFTService"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "JobRunner", path: "../../Packages/JobRunner"),
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
                "GemstonePrimitives",
                "JobRunner"
            ],
            path: "Sources"
        ),
        .target(
            name: "TransactionServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "StakeServiceTestKit", package: "StakeService"),
                .product(name: "NFTServiceTestKit", package: "NFTService"),
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                .product(name: "BalanceServiceTestKit", package: "BalanceService"),
                "TransactionService"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "TransactionServiceTests",
            dependencies: ["TransactionService"]
        ),
    ]
)

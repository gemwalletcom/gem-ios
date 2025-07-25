// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TransactionsService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "TransactionsService",
            targets: ["TransactionsService"]
        ),
        .library(
            name: "TransactionsServiceTestKit",
            targets: ["TransactionsServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "AssetsService", path: "../AssetsService"),
        .package(name: "DeviceService", path: "../DeviceService"),
    ],
    targets: [
        .target(
            name: "TransactionsService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Store",
                "Preferences",
                "AssetsService",
                "DeviceService",
            ],
            path: "Sources"
        ),
        .target(
            name: "TransactionsServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "AssetsServiceTestKit", package: "AssetsService"),
                "TransactionsService",
                .product(name: "DeviceServiceTestKit", package: "DeviceService"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "TransactionsServiceTests",
            dependencies: ["TransactionsService"]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NFTService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "NFTService",
            targets: ["NFTService"]
        ),
        .library(
            name: "NFTServiceTestKit",
            targets: ["NFTServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "DeviceService", path: "../DeviceService"),
    ],
    targets: [
        .target(
            name: "NFTService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "DeviceService",
            ],
            path: "Sources"
        ),
        .target(
            name: "NFTServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "NFTService",
                .product(name: "DeviceServiceTestKit", package: "DeviceService"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "NFTServiceTests",
            dependencies: ["NFTService"]
        ),
    ]
)

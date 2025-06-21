// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StakeService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "StakeService",
            targets: ["StakeService"]),
        .library(
            name: "StakeServiceTestKit",
            targets: ["StakeServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "ChainService", path: "../ChainService"),
    ],
    targets: [
        .target(
            name: "StakeService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "ChainService",
            ],
            path: "Sources"
        ),
        .target(
            name: "StakeServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                "Primitives",
                "StakeService"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "StakeServiceTests",
            dependencies: ["StakeService"]
        ),
    ]
)

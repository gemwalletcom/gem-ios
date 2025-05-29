// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NFTService",
    platforms: [
        .iOS(.v17)
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
    ],
    targets: [
        .target(
            name: "NFTService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI"
            ],
            path: "Sources"
        ),
        .target(
            name: "NFTServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "NFTService"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "NFTServiceTests",
            dependencies: ["NFTService"]
        ),
    ]
)

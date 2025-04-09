// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PriceService",
            targets: ["PriceService"]),
        .library(
            name: "PriceServiceTestKit",
            targets: ["PriceServiceTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
    ],
    targets: [
        .target(
            name: "PriceService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI"
            ],
            path: "Sources"
        ),
        .target(
            name: "PriceServiceTestKit",
            dependencies: [
                "PriceService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store"),
                "Primitives",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "PriceServiceTests",
            dependencies: [
                "PriceService",
            ]
        ),
    ]
)

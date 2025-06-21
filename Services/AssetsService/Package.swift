// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AssetsService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AssetsService",
            targets: ["AssetsService"]
        ),
        .library(
            name: "AssetsServiceTestKit",
            targets: ["AssetsServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "NodeService", path: "../NodeService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "GemstonePrimitives", path: ".../GemstonePrimitives")
    ],
    targets: [
        .target(
            name: "AssetsService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "ChainService",
                "NodeService",
                "Preferences",
                "GemstonePrimitives"
            ],
            path: "Sources"
        ),
        .target(
            name: "AssetsServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                "AssetsService",
                "Primitives",
                "Preferences",
                "GemstonePrimitives"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "AssetsServiceTests",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                "Primitives",
                "AssetsService",
                "AssetsServiceTestKit"
            ]
        ),
    ]
)

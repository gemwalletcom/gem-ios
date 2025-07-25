// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
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
        .package(name: "Preferences", path: "../../Packages/Preferences"),
    ],
    targets: [
        .target(
            name: "PriceService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "Preferences"
            ],
            path: "Sources"
        ),
        .target(
            name: "PriceServiceTestKit",
            dependencies: [
                "Primitives",
                "PriceService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "PriceServiceTests",
            dependencies: [
                "PriceServiceTestKit",
                .product(name: "PreferencesTestKit", package: "Preferences"),
            ]
        ),
    ]
)

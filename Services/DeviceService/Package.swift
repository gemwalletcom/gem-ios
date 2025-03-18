// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeviceService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DeviceService",
            targets: ["DeviceService"]
        ),
        .library(
            name: "DeviceServiceTestKit",
            targets: ["DeviceServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "Preferences", path: "../Preferences")
    ],
    targets: [
        .target(
            name: "DeviceService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences",
                "GemAPI",
            ],
            path: "Sources"
        ),
        .target(
            name: "DeviceServiceTestKit",
            dependencies: [
                "DeviceService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "TestKit"
        ),
    ]
)

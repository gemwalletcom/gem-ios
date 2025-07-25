// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeviceService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
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
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "Preferences", path: "../../Packages/Preferences")
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
        )
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceAlertService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PriceAlertService",
            targets: ["PriceAlertService"]
        ),
        .library(
            name: "PriceAlertServiceTestKit",
            targets: ["PriceAlertServiceTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "NotificationService", path: "../NotificationService"),
        .package(name: "DeviceService", path: "../DeviceService"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "PriceService", path: "../PriceService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
    ],
    targets: [
        .target(
            name: "PriceAlertService",
            dependencies: [
                "Primitives",
                "Store",
                "NotificationService",
                "DeviceService",
                "GemAPI",
                "PriceService",
                "Preferences"
            ],
            path: "Sources"
        ),
        .target(
            name: "PriceAlertServiceTestKit",
            dependencies: [
                "PriceAlertService",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "DeviceServiceTestKit", package: "DeviceService"),
                .product(name: "PriceServiceTestKit", package: "PriceService")
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "PriceAlertServiceTests",
            dependencies: ["PriceAlertService"]
        ),
    ]
)

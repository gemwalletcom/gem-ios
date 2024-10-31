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
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "NotificationService", path: "../NotificationService"),
        .package(name: "DeviceService", path: "../DeviceService"),
        .package(name: "GemAPI", path: "../GemAPI"),
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
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PriceAlertServiceTests",
            dependencies: ["PriceAlertService"]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceAlerts",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PriceAlerts",
            targets: ["PriceAlerts"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),

        .package(name: "Store", path: "../Store"),
        .package(name: "PriceAlertService", path: "../PriceAlertService"),
    ],
    targets: [
        .target(
            name: "PriceAlerts",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                "Store",
                "PriceAlertService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PriceAlertsTests",
            dependencies: ["PriceAlerts"]
        ),
    ]
)

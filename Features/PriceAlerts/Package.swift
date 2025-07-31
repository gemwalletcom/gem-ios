// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceAlerts",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "PriceAlerts",
            targets: ["PriceAlerts"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),

        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
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
                .product(name: "PriceAlertService", package: "FeatureServices"),
                "Preferences"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PriceAlertsTests",
            dependencies: [
                "PriceAlerts",
                .product(name: "PriceAlertServiceTestKit", package: "FeatureServices")
            ]
        ),
    ]
)

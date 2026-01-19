// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "InAppNotifications",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "InAppNotifications",
            targets: ["InAppNotifications"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
    ],
    targets: [
        .target(
            name: "InAppNotifications",
            dependencies: [
                "Primitives",
                "Localization",
                "Style",
                "Store",
                "Components",
                "PrimitivesComponents",
                .product(name: "NotificationService", package: "FeatureServices"),
            ],
            path: "Sources"
        ),
    ]
)

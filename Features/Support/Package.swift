// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Support",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Support",
            targets: ["Support"]
        )
    ],
    dependencies: [
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
    ],
    targets: [
        .target(
            name: "Support",
            dependencies: [
                "Style",
                "Components",
                "Primitives",
                "GemAPI",
                "Localization",
                "GemstonePrimitives",
                "PrimitivesComponents",
                "Preferences",
                .product(name: "NotificationService", package: "FeatureServices"),
                .product(name: "DeviceService", package: "FeatureServices")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SupportTests",
            dependencies: [
                "Support",
                .product(name: "PreferencesTestKit", package: "Preferences"),
            ]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ChainSettings",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ChainSettings",
            targets: ["ChainSettings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
    ],
    targets: [
        .target(
            name: "ChainSettings",
            dependencies: [
                "Primitives",
                "Style",
                "Localization",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ChainSettingsTests",
            dependencies: ["ChainSettings"]
        ),
    ]
)

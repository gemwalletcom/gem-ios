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
        .package(name: "Components", path: "../Components"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "NodeService", path: "../NodeService"),
    ],
    targets: [
        .target(
            name: "ChainSettings",
            dependencies: [
                "Primitives",
                "Style",
                "Components",
                "Localization",
                "ChainService",
                "NodeService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ChainSettingsTests",
            dependencies: ["ChainSettings"]
        ),
    ]
)

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
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "NodeService", path: "../NodeService"),
        .package(name: "QRScanner", path: "../QRScanner"),

    ],
    targets: [
        .target(
            name: "ChainSettings",
            dependencies: [
                "Primitives",
                "Style",
                "Components",
                "Localization",
                "PrimitivesComponents",
                "ChainService",
                "NodeService",
                "QRScanner",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ChainSettingsTests",
            dependencies: ["ChainSettings"]
        ),
    ]
)

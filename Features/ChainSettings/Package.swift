// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ChainSettings",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "ChainSettings",
            targets: ["ChainSettings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "ChainService", path: "../../Services/ChainService"),
        .package(name: "NodeService", path: "../../Services/NodeService"),
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "QRScanner", path: "../QRScanner"),
    ],
    targets: [
        .target(
            name: "ChainSettings",
            dependencies: [
                "Primitives",
                "Formatters",
                "Style",
                "Components",
                "Localization",
                "PrimitivesComponents",
                "ChainService",
                "NodeService",
                "ExplorerService",
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

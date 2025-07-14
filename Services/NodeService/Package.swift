// swift-tools-version: 6.0

import PackageDescription
let package = Package(
    name: "NodeService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "NodeService",
            targets: ["NodeService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "ChainService", path: "../ChainService"),
    ],
    targets: [
        .target(
            name: "NodeService",
            dependencies: [
                "Primitives",
                "Store",
                "Gemstone",
                "ChainService",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NodeServiceTests",
            dependencies: ["NodeService"]
        ),
    ]
)

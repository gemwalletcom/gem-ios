// swift-tools-version: 6.0

import PackageDescription
let package = Package(
    name: "NodeService",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "NodeService",
            targets: ["NodeService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Gemstone", path: "../Gemstone"),
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

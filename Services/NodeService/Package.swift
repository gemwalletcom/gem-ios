// swift-tools-version: 6.0

import PackageDescription
let package = Package(
    name: "NodeService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "NodeService",
            targets: ["NodeService"]),
        .library(
            name: "NodeServiceTestKit",
            targets: ["NodeServiceTestKit"]),
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
        .target(
            name: "NodeServiceTestKit",
            dependencies: [
                "NodeService",
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "NodeServiceTests",
            dependencies: ["NodeService"]
        ),
    ]
)

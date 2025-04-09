// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ChainService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ChainService",
            targets: ["ChainService"]
        ),
        .library(
            name: "ChainServiceTestKit",
            targets: ["ChainServiceTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
    ],
    targets: [
        .target(
            name: "ChainService",
            dependencies: [
                "Primitives",
                "Blockchain",
            ],
            path: "Sources"
        ),
        .target(
            name: "ChainServiceTestKit",
            dependencies: [
                "Primitives",
                "Blockchain",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "ChainServiceTests",
            dependencies: ["ChainService"]
        ),
    ]
)

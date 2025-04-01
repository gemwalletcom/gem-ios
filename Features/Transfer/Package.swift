// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transfer",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Transfer",
            targets: ["Transfer"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
    ],
    targets: [
        .target(
            name: "Transfer",
            dependencies: [
                "Primitives",
                "Localization",
                "Components",
                "Blockchain",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransferTests",
            dependencies: [
                "Transfer",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        ),
    ]
)

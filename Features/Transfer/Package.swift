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
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Localization", path: "../Localization"),
    ],
    targets: [
        .target(
            name: "Transfer",
            dependencies: [
                "Primitives",
                "Localization"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransferTests",
            dependencies: ["Transfer"],
            path: "Tests"
        ),
    ]
)

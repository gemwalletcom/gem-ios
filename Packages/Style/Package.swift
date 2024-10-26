// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Style",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Style",
            targets: ["Style"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Style",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "StyleTests",
            dependencies: ["Style"]),
    ]
)

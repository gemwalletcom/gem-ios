// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Style",
    platforms: [.iOS(.v16), .macOS(.v12)],
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

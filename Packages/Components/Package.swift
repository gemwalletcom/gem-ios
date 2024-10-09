// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]),
    ],
    dependencies: [
        .package(name: "Style", path: "../Style"),
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                "Style",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"]),
    ]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfoSheet",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "InfoSheet",
            targets: ["InfoSheet"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Components", path: "../Components"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives")
    ],
    targets: [
        .target(
            name: "InfoSheet",
            dependencies: [
                "Primitives",
                "Style",
                "Localization",
                "Components",
                "GemstonePrimitives",
            ],
            path: "Sources"
        ),
    ]
)

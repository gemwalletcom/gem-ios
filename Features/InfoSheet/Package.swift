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
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Components", path: "../Components"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives")
    ],
    targets: [
        .target(
            name: "InfoSheet",
            dependencies: [
                "Localization",
                "Components",
                "GemstonePrimitives",
            ],
            path: "Sources"
        ),
    ]
)

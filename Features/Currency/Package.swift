// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Currency",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Currency",
            targets: ["Currency"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Localization", path: "../Localization"),
    ],
    targets: [
        .target(
            name: "Currency",
            dependencies: [
                "Primitives",
                "Components",
                "Localization"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CurrencyTests",
            dependencies: ["Currency"]
        ),
    ]
)

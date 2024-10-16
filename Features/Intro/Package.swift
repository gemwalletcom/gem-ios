// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Intro",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Intro",
            targets: ["Intro"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
    ],
    targets: [
        .target(
            name: "Intro",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
            ],
            path: "Sources"
        ),

    ]
)

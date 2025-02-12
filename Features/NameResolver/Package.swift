// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NameResolver",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NameResolver",
            targets: ["NameResolver"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "GemAPI", path: "../GemAPI"),
    ],
    targets: [
        .target(
            name: "NameResolver",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "GemAPI"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NameResolverTests",
            dependencies: ["NameResolver"]
        ),
    ]
)

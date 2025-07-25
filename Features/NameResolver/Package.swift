// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NameResolver",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "NameResolver",
            targets: ["NameResolver"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
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

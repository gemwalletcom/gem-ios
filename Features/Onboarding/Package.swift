// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
    ],
    targets: [
        .target(
            name: "Onboarding",
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

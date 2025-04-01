// swift-tools-version: 6.0

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
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
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

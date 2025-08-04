// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "InfoSheet",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "InfoSheet",
            targets: ["InfoSheet"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents")
    ],
    targets: [
        .target(
            name: "InfoSheet",
            dependencies: [
                "Primitives",
                "Style",
                "Localization",
                "Components",
                "Formatters",
                "GemstonePrimitives",
                "PrimitivesComponents"
            ],
            path: "Sources"
        ),
    ]
)

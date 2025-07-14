// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceWidget",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PriceWidget",
            targets: ["PriceWidget"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "PriceWidget",
            dependencies: [
                "Primitives",
                "Components",
                "Formatters",
                "Style",
                "Store",
                "PriceService",
                "Localization",
                "GemstonePrimitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PriceWidgetTests",
            dependencies: [
                "PriceWidget",
            ],
            path: "Tests"
        ),
    ]
)

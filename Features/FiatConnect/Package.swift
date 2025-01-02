// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FiatConnect",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "FiatConnect",
            targets: ["FiatConnect"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Store", path: "../Store"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
    ],
    targets: [
        .target(
            name: "FiatConnect",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Style",
                "Components",
                "Localization",
                "Store",
                "PrimitivesComponents"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FiatConnectTests",
            dependencies: [
                "FiatConnect",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        ),
    ]
)

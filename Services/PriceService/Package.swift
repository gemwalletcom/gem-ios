// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PriceService",
            targets: ["PriceService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
    ],
    targets: [
        .target(
            name: "PriceService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PriceServiceTests",
            dependencies: ["PriceService"]
        ),
    ]
)

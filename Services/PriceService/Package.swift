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
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
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

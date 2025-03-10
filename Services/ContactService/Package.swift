// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContactService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ContactService",
            targets: ["ContactService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
    ],
    targets: [
        .target(
            name: "ContactService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI"
            ]),
    ]
)

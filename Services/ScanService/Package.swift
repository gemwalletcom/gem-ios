// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScanService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ScanService",
            targets: ["ScanService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "Preferences", path: "../Preferences"),
    ],
    targets: [
        .target(
            name: "ScanService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Preferences",
            ],
            path: "Sources"
        ),
    ]
)

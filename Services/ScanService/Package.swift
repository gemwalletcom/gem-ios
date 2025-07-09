// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScanService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ScanService",
            targets: ["ScanService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
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

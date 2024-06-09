// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Settings",
            targets: ["Settings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
    ],
    targets: [
        .target(
            name: "Settings",
            dependencies: [
                "Primitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]),
    ]
)

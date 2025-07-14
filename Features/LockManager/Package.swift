// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LockManager",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "LockManager",
            targets: ["LockManager"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
    ],
    targets: [
        .target(
            name: "LockManager",
            dependencies: [
                "Primitives",
                "Style",
                "Components",
                "Localization",
                "Keystore"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "LockManagerTests",
            dependencies: ["LockManager"]
        ),
    ]
)

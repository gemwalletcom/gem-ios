// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LockManager",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "LockManager",
            targets: ["LockManager"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Keystore", path: "../Keystore"),
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

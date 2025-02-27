// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AvatarService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AvatarService",
            targets: ["AvatarService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "FileStore", path: "../FileStore")
    ],
    targets: [
        .target(
            name: "AvatarService",
            dependencies: [
                "Primitives",
                "Store",
                "FileStore"
            ],
            path: "Sources"
        )
    ]
)

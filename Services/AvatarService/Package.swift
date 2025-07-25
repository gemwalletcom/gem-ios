// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AvatarService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AvatarService",
            targets: ["AvatarService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store")
    ],
    targets: [
        .target(
            name: "AvatarService",
            dependencies: [
                "Primitives",
                "Store"
            ],
            path: "Sources"
        )
    ]
)

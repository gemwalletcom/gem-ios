// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvatarToolkit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "AvatarToolkit",
            targets: ["AvatarToolkit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "Store", path: "../Store"),
        .package(name: "ImageGalleryService", path: "../ImageGalleryService")
    ],
    targets: [
        .target(
            name: "AvatarToolkit",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                "Store",
                "ImageGalleryService"
            ],
            path: "Sources"
        ),
    ]
)

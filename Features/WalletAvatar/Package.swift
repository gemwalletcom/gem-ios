// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalletAvatar",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "WalletAvatar",
            targets: ["WalletAvatar"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "Store", path: "../Store"),
        .package(name: "ImageGalleryService", path: "../ImageGalleryService"),
        .package(name: "AvatarService", path: "../AvatarService"),
    ],
    targets: [
        .target(
            name: "WalletAvatar",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                "Store",
                "ImageGalleryService",
                "AvatarService"
            ],
            path: "Sources"
        ),
    ]
)

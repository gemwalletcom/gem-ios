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
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "ImageGalleryService", path: "../../Services/ImageGalleryService"),
        .package(name: "AvatarService", path: "../../Services/AvatarService"),
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

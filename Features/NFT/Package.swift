// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NFT",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "NFT",
            targets: ["NFT"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "DeviceService", path: "../DeviceService"),
        .package(name: "NFTService", path: "../NFTService"),
        .package(name: "Store", path: "../Store"),
        .package(name: "ImageGalleryService", path: "../ImageGalleryService"),
        .package(name: "ManageWalletService", path: "../ManageWalletService"),
    ],
    targets: [
        .target(
            name: "NFT",
            dependencies: [
                "Primitives",
                "Components",
                "PrimitivesComponents",
                "Style",
                "Localization",
                "DeviceService",
                "NFTService",
                "Store",
                "ImageGalleryService",
                "ManageWalletService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NFTTests",
            dependencies: ["NFT"]
        )
    ]
)

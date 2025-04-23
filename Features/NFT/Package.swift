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
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "DeviceService", path: "../../Services/DeviceService"),
        .package(name: "NFTService", path: "../../Services/NFTService"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "ImageGalleryService", path: "../../Services/ImageGalleryService"),
        .package(name: "WalletService", path: "../../Services/WalletService"),
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
                "WalletService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NFTTests",
            dependencies: ["NFT"]
        )
    ]
)

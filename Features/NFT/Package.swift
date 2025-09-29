// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NFT",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
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
        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
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
                .product(name: "DeviceService", package: "FeatureServices"),
                .product(name: "NFTService", package: "FeatureServices"),
                "Store",
                .product(name: "ImageGalleryService", package: "SystemServices"),
                .product(name: "WalletService", package: "FeatureServices"),
                "Formatters",
                .product(name: "ExplorerService", package: "ChainServices"),
                .product(name: "AvatarService", package: "FeatureServices")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NFTTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "WalletServiceTestKit", package: "FeatureServices"),
                "NFT",
                "PrimitivesComponents",
                .product(name: "AvatarService", package: "FeatureServices"),
                "Store"
            ]
        )
    ]
)

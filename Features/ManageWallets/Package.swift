// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ManageWallets",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "ManageWallets",
            targets: ["ManageWallets"])
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "Onboarding", path: "../Onboarding")
    ],
    targets: [
        .target(
            name: "ManageWallets",
            dependencies: [
                "Primitives",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "Store",
                "Keystore",
                .product(name: "ExplorerService", package: "ChainServices"),
                .product(name: "WalletService", package: "FeatureServices"),
                .product(name: "ImageGalleryService", package: "SystemServices"),
                .product(name: "AvatarService", package: "FeatureServices"),
                "Onboarding"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ManageWalletsTests",
            dependencies: [
                "ManageWallets",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletServiceTestKit", package: "FeatureServices"),
                .product(name: "StoreTestKit", package: "Store")
            ]
        )
    ]
)

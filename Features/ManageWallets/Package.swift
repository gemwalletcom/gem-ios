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
            targets: ["ManageWallets"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "WalletService", path: "../../Services/WalletService"),
        .package(name: "ImageGalleryService", path: "../../Services/ImageGalleryService"),
        .package(name: "AvatarService", path: "../../Services/AvatarService"),
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
                "ExplorerService",
                "WalletService",
                "ImageGalleryService",
                "AvatarService",
                "Onboarding"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ManageWalletsTest",
            dependencies: ["ManageWallets"]
        ),
    ]
)

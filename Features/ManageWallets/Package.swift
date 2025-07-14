// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ManageWallets",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
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
        .package(name: "WalletAvatar", path: "../WalletAvatar"),
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
                "WalletAvatar",
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

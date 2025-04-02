// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletTab",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WalletTab",
            targets: ["WalletTab"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "InfoSheet", path: "../InfoSheet"),

        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "BalanceService", path: "../../Services/BalanceService"),
        .package(name: "WalletsService", path: "../../Services/WalletsService"),
        .package(name: "BannerService", path: "../../Services/BannerService"),
        .package(name: "WalletAvatar", path: "../WalletAvatar"),
        .package(name: "ManageWalletService", path: "../ManageWalletService"),
    ],
    targets: [
        .target(
            name: "WalletTab",
            dependencies: [
                "Primitives",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "InfoSheet",
                "Store",
                "Preferences",
                "BalanceService",
                "WalletsService",
                "BannerService",
                "WalletAvatar",
                "ManageWalletService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletTabTests",
            dependencies: ["WalletTab"]
        ),
    ]
)

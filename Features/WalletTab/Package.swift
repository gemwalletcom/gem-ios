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
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Components", path: "../Components"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "InfoSheet", path: "../InfoSheet"),

        .package(name: "Store", path: "../Store"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "BalanceService", path: "../BalanceService"),
        .package(name: "WalletsService", path: "../WalletsService"),
        .package(name: "BannerService", path: "../BannerService"),
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
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletTabTests",
            dependencies: ["WalletTab"]
        ),
    ]
)

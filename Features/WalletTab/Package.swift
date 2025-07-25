// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletTab",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WalletTab",
            targets: ["WalletTab"]
        ),
        .library(
            name: "WalletTabTestKit",
            targets: ["WalletTabTestKit"]
        )
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
        .package(name: "WalletService", path: "../WalletService"),
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
                "WalletService"
            ],
            path: "Sources"
        ),
        .target(
            name: "WalletTabTestKit",
            dependencies: [
                .product(name: "WalletsServiceTestKit", package: "WalletsService"),
                .product(name: "BannerServiceTestKit", package: "BannerService"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletServiceTestKit", package: "WalletService"),
                "WalletTab"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "WalletTabTests",
            dependencies: [
                .product(name: "WalletsServiceTestKit", package: "WalletsService"),
                .product(name: "BannerServiceTestKit", package: "BannerService"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletServiceTestKit", package: "WalletService"),
                "WalletTab"
            ]
        ),
    ]
)

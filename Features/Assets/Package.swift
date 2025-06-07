// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Assets",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Assets",
            targets: ["Assets"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "PriceAlertService", path: "../../Services/PriceAlertService"),
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "AssetsService", path: "../../Services/AssetsService"),
        .package(name: "TransactionsService", path: "../../Services/TransactionsService"),
        .package(name: "WalletsService", path: "../../Services/WalletsService"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
        .package(name: "BannerService", path: "../../Services/BannerService"),
        .package(name: "ChainService", path: "../../Services/ChainService")
    ],
    targets: [
        .target(
            name: "Assets",
            dependencies: [
                "Primitives",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "Store",
                "Preferences",
                "Blockchain",
                "InfoSheet",
                "QRScanner",
                "PriceAlertService",
                "ExplorerService",
                "AssetsService",
                "TransactionsService",
                "WalletsService",
                "PriceService",
                "BannerService",
                "ChainService"
            ]
        )
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Assets",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Assets",
            targets: ["Assets"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices")
    ],
    targets: [
        .target(
            name: "Assets",
            dependencies: [
                "Primitives",
                "Formatters",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "Store",
                "Preferences",
                "Blockchain",
                "InfoSheet",
                "QRScanner",
                .product(name: "PriceAlertService", package: "FeatureServices"),
                .product(name: "ExplorerService", package: "ChainServices"),
                .product(name: "AssetsService", package: "FeatureServices"),
                .product(name: "TransactionsService", package: "FeatureServices"),
                .product(name: "WalletsService", package: "FeatureServices"),
                .product(name: "PriceService", package: "FeatureServices"),
                .product(name: "BannerService", package: "FeatureServices"),
                .product(name: "ChainService", package: "ChainServices")
            ]
        ),
        .testTarget(
            name: "AssetsTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletsServiceTestKit", package: "FeatureServices"),
                .product(name: "AssetsServiceTestKit", package: "FeatureServices"),
                .product(name: "TransactionsServiceTestKit", package: "FeatureServices"),
                .product(name: "PriceServiceTestKit", package: "FeatureServices"),
                .product(name: "PriceAlertServiceTestKit", package: "FeatureServices"),
                .product(name: "BannerServiceTestKit", package: "FeatureServices"),
                .product(name: "BalanceServiceTestKit", package: "FeatureServices"),
                .product(name: "TransactionServiceTestKit", package: "FeatureServices"),
                "Assets"
            ]
        )
    ]
)

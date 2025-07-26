// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Settings",
            targets: ["Settings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),

        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "WalletsService", path: "../../Services/WalletsService"),
        .package(name: "BannerService", path: "../../Services/BannerService"),
        .package(name: "StakeService", path: "../../Services/StakeService"),
        .package(name: "AssetsService", path: "../../Services/AssetsService"),
        .package(name: "TransactionsService", path: "../../Services/TransactionsService"),
        .package(name: "NotificationService", path: "../../Services/NotificationService"),
        .package(name: "DeviceService", path: "../../Services/DeviceService"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
        .package(name: "AppService", path: "../../AppService"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "ChainService", path: "../../Services/ChainService"),
        .package(name: "NodeService", path: "../../Services/NodeService"),
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "QRScanner", path: "../QRScanner")
    ],
    targets: [
        .target(
            name: "Settings",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                "Preferences",
                "GemstonePrimitives",
                "Gemstone",
                "Keystore",
                "WalletsService",
                "BannerService",
                "StakeService",
                "AssetsService",
                "TransactionsService",
                "NotificationService",
                "DeviceService",
                "PriceService",
                "AppService",
                "Formatters",
                "ChainService",
                "NodeService",
                "ExplorerService",
                "QRScanner"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]),
    ]
)

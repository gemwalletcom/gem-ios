// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Settings",
            targets: ["Settings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "Currency", path: "../Currency"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Gemstone", path: "../Gemstone"),

        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "WalletsService", path: "../WalletsService"),
        .package(name: "BannerService", path: "../BannerService"),
        .package(name: "StakeService", path: "../StakeService"),
        .package(name: "AssetsService", path: "../AssetsService"),
        .package(name: "TransactionsService", path: "../TransactionsService"),
        .package(name: "NotificationService", path: "../NotificationService"),
        .package(name: "DeviceService", path: "../DeviceService"),
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
                "Currency",
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
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]),
    ]
)

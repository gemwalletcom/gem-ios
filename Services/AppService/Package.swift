// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AppService",
            targets: ["AppService"]
        )
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
        .package(name: "NodeService", path: "../NodeService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "BannerService", path: "../BannerService"),
        .package(name: "DeviceService", path: "../DeviceService"),
        .package(name: "SwapService", path: "../../Services/SwapService"),
        .package(name: "AssetsService", path: "../AssetsService"),
        .package(name: "WalletService", path: "../WalletService"),
    ],
    targets: [
        .target(
            name: "AppService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "NodeService",
                "Preferences",
                "BannerService",
                "DeviceService",
                "SwapService",
                "AssetsService",
                "WalletService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AppServiceTests",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "AssetsServiceTestKit", package: "AssetsService"),
                .product(name: "DeviceServiceTestKit", package: "DeviceService"),
                .product(name: "BannerServiceTestKit", package: "BannerService"),
                "Primitives",
                "AppService"
            ]
        ),
    ]
)

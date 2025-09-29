// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SystemServices",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "NotificationService", targets: ["NotificationService"]),
        .library(name: "NotificationServiceTestKit", targets: ["NotificationServiceTestKit"]),
        .library(name: "DeviceService", targets: ["DeviceService"]),
        .library(name: "DeviceServiceTestKit", targets: ["DeviceServiceTestKit"]),
        .library(name: "ImageGalleryService", targets: ["ImageGalleryService"]),
        .library(name: "NativeProviderService", targets: ["NativeProviderService"]),
        .library(name: "WalletSessionService", targets: ["WalletSessionService"]),
        .library(name: "WalletSessionServiceTestKit", targets: ["WalletSessionServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "Store", path: "../Store"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "WalletCore", path: "../WalletCore"),
    ],
    targets: [
        .target(
            name: "NotificationService",
            dependencies: [
                "Preferences"
            ],
            path: "NotificationService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "NotificationServiceTestKit",
            dependencies: [
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "NotificationService"
            ],
            path: "NotificationService/TestKit"
        ),
        .target(
            name: "DeviceService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences",
                "GemAPI",
            ],
            path: "DeviceService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "DeviceServiceTestKit",
            dependencies: [
                "DeviceService",
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "StoreTestKit", package: "Store")
            ],
            path: "DeviceService/TestKit"
        ),
        .target(
            name: "ImageGalleryService",
            dependencies: [],
            path: "ImageGalleryService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "NativeProviderService",
            dependencies: [
                "Primitives",
                "Gemstone",
                .product(name: "WalletCore", package: "WalletCore"),
            ],
            path: "NativeProviderService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "WalletSessionService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences"
            ],
            path: "WalletSessionService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "WalletSessionServiceTestKit",
            dependencies: [
                "WalletSessionService",
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "WalletSessionService/TestKit"
        ),
    ]
)

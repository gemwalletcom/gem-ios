// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WalletService",
            targets: ["WalletService"]
        ),
        .library(
            name: "WalletServiceTestKit",
            targets: ["WalletServiceTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "AvatarService", path: "../AvatarService"),
        .package(name: "WalletSessionService", path: "../WalletSessionService"),
    ],
    targets: [
        .target(
            name: "WalletService",
            dependencies: [
                "Primitives",
                "Keystore",
                "Store",
                "Preferences",
                "AvatarService",
                "WalletSessionService"
            ],
            path: "Sources"
        ),
        .target(
            name: "WalletServiceTestKit",
            dependencies: [
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
                "WalletService"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "WalletServiceTests",
            dependencies: [
                "WalletService",
                "WalletServiceTestKit",
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "Tests"
        ),
    ]
)

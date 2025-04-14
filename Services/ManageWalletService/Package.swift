// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ManageWalletService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ManageWalletService",
            targets: ["ManageWalletService"]),
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
            name: "ManageWalletService",
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
        .testTarget(
            name: "ManageWalletServiceTests",
            dependencies: ["ManageWalletService"]
        ),
    ]
)

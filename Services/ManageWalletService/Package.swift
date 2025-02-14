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
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Preferences", path: "../Preferences"),
    ],
    targets: [
        .target(
            name: "ManageWalletService",
            dependencies: [
                "Primitives",
                "Keystore",
                "Store",
                "Preferences"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ManageWalletServiceTests",
            dependencies: ["ManageWalletService"]
        ),
    ]
)

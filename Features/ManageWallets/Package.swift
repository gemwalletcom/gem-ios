// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ManageWallets",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ManageWallets",
            targets: ["ManageWallets"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Components", path: "../Components"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),

        .package(name: "Store", path: "../Store"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "ExplorerService", path: "../ExplorerService"),
        .package(name: "ManageWalletService", path: "../ManageWalletService"),
    ],
    targets: [
        .target(
            name: "ManageWallets",
            dependencies: [
                "Primitives",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "Store",
                "Keystore",
                "ExplorerService",
                "ManageWalletService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ManageWalletsTest",
            dependencies: ["ManageWallets"]
        ),
    ]
)

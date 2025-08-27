// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletConnector",
    platforms: [.iOS(.v17),
        .macOS(.v15)],
    products: [
        .library(
            name: "WalletConnector",
            targets: ["WalletConnector"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
    ],
    targets: [
        .target(
            name: "WalletConnector",
            dependencies: [
                "Primitives",
                .product(name: "WalletConnectorService", package: "ChainServices"),
                "Components",
                "Localization",
                "Style",
                "Store",
                "Preferences",
                "PrimitivesComponents",
                "QRScanner",
                .product(name: "WalletSessionService", package: "SystemServices"),
                "Keystore",
                "Gemstone"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletConnectorTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "WalletSessionServiceTestKit", package: "SystemServices"),
                .product(name: "WalletConnectorServiceTestKit", package: "ChainServices"),
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
                .product(name: "AssetsServiceTestKit", package: "FeatureServices"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "WalletConnector",
                "Gemstone"
            ],
            resources: [.process("Resources")]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transfer",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Transfer",
            targets: ["Transfer"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
        .package(name: "Signer", path: "../../Packages/Signer"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "Validators", path: "../../Packages/Validators"),

        .package(name: "Staking", path: "../Staking"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "WalletConnector", path: "../WalletConnector"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "FiatConnect", path: "../FiatConnect"),
        .package(name: "Swap", path: "../Swap"),

        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI")
    ],
    targets: [
        .target(
            name: "Transfer",
            dependencies: [
                "Primitives",
                "Formatters",
                "Localization",
                "Style",
                "Components",
                "PrimitivesComponents",
                "GemstonePrimitives",
                "Keystore",
                "Blockchain",
                "Signer",
                "Preferences",
                "Validators",

                "Staking",
                "QRScanner",
                "WalletConnector",
                "InfoSheet",
                "FiatConnect",
                "Swap",

                .product(name: "ChainService", package: "ChainServices"),
                .product(name: "WalletService", package: "SystemServices"),
                .product(name: "WalletsService", package: "SystemServices"),
                .product(name: "StakeService", package: "ChainServices"),
                .product(name: "NodeService", package: "ChainServices"),
                .product(name: "TransactionService", package: "FeatureServices"),
                .product(name: "ScanService", package: "ChainServices"),
                .product(name: "BalanceService", package: "FeatureServices"),
                .product(name: "PriceService", package: "FeatureServices"),
                .product(name: "ExplorerService", package: "ChainServices"),
                .product(name: "NameService", package: "ChainServices")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransferTests",
            dependencies: [
                "Transfer",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StakeServiceTestKit", package: "ChainServices"),
                .product(name: "WalletsServiceTestKit", package: "SystemServices"),
                .product(name: "BlockchainTestKit", package: "Blockchain"),
                .product(name: "ScanServiceTestKit", package: "ChainServices"),
                .product(name: "SwapServiceTestKit", package: "FeatureServices"),
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "WalletServiceTestKit", package: "SystemServices"),
                .product(name: "NameServiceTestKit", package: "ChainServices"),
                .product(name: "NodeServiceTestKit", package: "ChainServices"),
                .product(name: "PriceServiceTestKit", package: "FeatureServices"),
                .product(name: "AssetsServiceTestKit", package: "FeatureServices"),
                .product(name: "BalanceServiceTestKit", package: "FeatureServices"),
                .product(name: "TransactionServiceTestKit", package: "FeatureServices"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                .product(name: "ChainServiceTestKit", package: "ChainServices"),
            ],
            path: "Tests"
        ),
    ]
)

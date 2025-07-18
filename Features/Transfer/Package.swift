// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transfer",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
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
        .package(name: "Store", path: "../../Packages/Store"),

        .package(name: "Staking", path: "../Staking"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "NameResolver", path: "../NameResolver"),
        .package(name: "WalletConnector", path: "../WalletConnector"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
        .package(name: "FiatConnect", path: "../FiatConnect"),

        .package(name: "ChainService", path: "../../Services/ChainService"),
        .package(name: "WalletService", path: "../../Services/WalletService"),
        .package(name: "WalletsService", path: "../../Services/WalletsService"),
        .package(name: "StakeService", path: "../../Services/StakeService"),
        .package(name: "NodeService", path: "../../Services/NodeService"),
        .package(name: "TransactionService", path: "../../Services/TransactionService"),
        .package(name: "ScanService", path: "../../Services/ScanService"),
        .package(name: "BalanceService", path: "../../Services/BalanceService"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
        .package(name: "ExplorerService", path: "../../Services/ExplorerService"),
        .package(name: "SwapService", path: "../../Services/SwapService"),
        .package(name: "AddressNameService", path: "../../Services/AddressNameService")
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
                "NameResolver",
                "WalletConnector",
                "InfoSheet",
                "FiatConnect",

                "ChainService",
                "WalletService",
                "WalletsService",
                "StakeService",
                "NodeService",
                "TransactionService",
                "ScanService",
                "BalanceService",
                "PriceService",
                "ExplorerService",
                "SwapService",
                "AddressNameService"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransferTests",
            dependencies: [
                "Transfer",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StakeServiceTestKit", package: "StakeService"),
                .product(name: "WalletsServiceTestKit", package: "WalletsService"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "BlockchainTestKit", package: "Blockchain"),
                .product(name: "ScanServiceTestKit", package: "ScanService"),
                .product(name: "SwapServiceTestKit", package: "SwapService"),
                .product(name: "KeystoreTestKit", package: "Keystore"),
            ],
            path: "Tests"
        ),
    ]
)

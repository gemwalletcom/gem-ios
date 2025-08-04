// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ChainServices",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "NameService", targets: ["NameService"]),
        .library(name: "NameServiceTestKit", targets: ["NameServiceTestKit"]),
        .library(name: "StakeService", targets: ["StakeService"]),
        .library(name: "StakeServiceTestKit", targets: ["StakeServiceTestKit"]),
        .library(name: "NodeService", targets: ["NodeService"]),
        .library(name: "NodeServiceTestKit", targets: ["NodeServiceTestKit"]),
        .library(name: "WalletConnectorService", targets: ["WalletConnectorService"]),
        .library(name: "WalletConnectorServiceTestKit", targets: ["WalletConnectorServiceTestKit"]),
        .library(name: "ScanService", targets: ["ScanService"]),
        .library(name: "ScanServiceTestKit", targets: ["ScanServiceTestKit"]),
        .library(name: "ExplorerService", targets: ["ExplorerService"]),
        .library(name: "ChainService", targets: ["ChainService"]),
        .library(name: "ChainServiceTestKit", targets: ["ChainServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "GemAPI", path: "../GemAPI"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Blockchain", path: "../Blockchain"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(url: "https://github.com/gemwalletcom/reown-swift.git", revision: "f061a10"),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: Version(stringLiteral: "3.1.2")),
    ],
    targets: [
        .target(
            name: "NameService",
            dependencies: [
                "Primitives",
                "PrimitivesComponents",
                "GemAPI"
            ],
            path: "NameService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "NameServiceTestKit",
            dependencies: [
                "NameService",
                "PrimitivesComponents",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "NameService/TestKit"
        ),
        .target(
            name: "StakeService",
            dependencies: [
                "Primitives",
                "Store",
                "GemAPI",
                "ChainService",
            ],
            path: "StakeService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "StakeServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "GemAPITestKit", package: "GemAPI"),
                "ChainServiceTestKit",
                "Primitives",
                "StakeService"
            ],
            path: "StakeService/TestKit"
        ),
        .target(
            name: "NodeService",
            dependencies: [
                "Primitives",
                "Store",
                "ChainService",
            ],
            path: "NodeService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "NodeServiceTestKit",
            dependencies: [
                "NodeService",
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "NodeService/TestKit"
        ),
        .target(
            name: "WalletConnectorService",
            dependencies: [
                "Primitives",
                "Gemstone",
                "GemstonePrimitives",
                .product(name: "WalletConnect", package: "reown-swift"),
                .product(name: "ReownWalletKit", package: "reown-swift"),
                .product(name: "Starscream", package: "Starscream"),
            ],
            path: "WalletConnectorService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "WalletConnectorServiceTestKit",
            dependencies: ["WalletConnectorService"],
            path: "WalletConnectorService/TestKit"
        ),
        .target(
            name: "ScanService",
            dependencies: [
                "Primitives",
                "GemAPI",
                "Preferences",
            ],
            path: "ScanService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "ScanServiceTestKit",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "ScanService",
                "Primitives",
                "GemAPI",
                .product(name: "PreferencesTestKit", package: "Preferences"),
            ],
            path: "ScanService/TestKit"
        ),
        .target(
            name: "ExplorerService",
            dependencies: [
                "Primitives",
                "GemstonePrimitives",
                "Preferences"
            ],
            path: "ExplorerService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "ChainService",
            dependencies: [
                "Primitives",
                "Blockchain",
            ],
            path: "ChainService",
            exclude: ["TestKit"]
        ),
        .target(
            name: "ChainServiceTestKit",
            dependencies: [
                "ChainService",
                "Primitives",
                "Blockchain",
            ],
            path: "ChainService/TestKit"
        ),
    ]
)

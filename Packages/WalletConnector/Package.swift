// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WalletConnector",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "WalletConnector",
            targets: ["WalletConnector"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(url: "https://github.com/WalletConnect/WalletConnectSwiftV2", exact: Version(stringLiteral: "1.20.3")),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: Version(stringLiteral: "3.1.2")),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "WalletConnector",
            dependencies: [
                "Primitives",
                "Gemstone",
                "GemstonePrimitives",
                .product(
                    name: "WalletConnect",
                    package: "WalletConnectSwiftV2"
                ),
                .product(
                    name: "Web3Wallet",
                    package: "WalletConnectSwiftV2"
                ),
                .product(name: "Starscream", package: "Starscream"),
            ],
            path: "Sources"
        ),
//        .testTarget(
//            name: "WalletConnectorTests",
//            dependencies: ["WalletConnector"]
//        ),
    ]
)

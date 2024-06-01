// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WalletConnector",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        .library(
            name: "WalletConnector",
            targets: ["WalletConnector"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(url: "https://github.com/WalletConnect/WalletConnectSwiftV2", .exactItem(Version(stringLiteral: "1.18.8"))),
        .package(url: "https://github.com/daltoniam/Starscream.git", .exactItem(Version(stringLiteral: "3.1.2"))),
        .package(name: "Gemstone", path: "../Gemstone"),
    ],
    targets: [
        .target(
            name: "WalletConnector",
            dependencies: [
                "Primitives",
                "Gemstone",
                .product(
                    name: "WalletConnect",
                    package: "WalletConnectSwiftV2"
                ),
                .product(
                    name: "WalletConnectAuth",
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

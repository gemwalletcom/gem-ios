// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Signer",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Signer",
            targets: ["Signer"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "Blockchain", path: "../Blockchain"),
        .package(url: "https://github.com/gemwalletcom/wallet-core-release", exact: Version(stringLiteral: "4.1.5")),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
    ],
    targets: [
        .target(
            name: "Signer",
            dependencies: [
                "Primitives",
                "Keystore",
                "Blockchain",
                .product(name: "WalletCore", package: "wallet-core-release"),
                .product(name: "SwiftProtobuf", package: "wallet-core-release"),
                "WalletCorePrimitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SignerTests",
            dependencies: ["Signer"]),
    ]
)

// swift-tools-version: 6.0
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
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
    ],
    targets: [
        .target(
            name: "Signer",
            dependencies: [
                "Primitives",
                "Keystore",
                "Blockchain",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "SwiftProtobuf", package: "WalletCore"),
                "WalletCorePrimitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SignerTests",
            dependencies: ["Signer"]),
    ]
)

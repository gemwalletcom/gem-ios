// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Signer",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "Signer",
            targets: ["Signer"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "Blockchain", path: "../Blockchain"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "Keychain", path: "../Keychain"),
    ],
    targets: [
        .target(
            name: "Signer",
            dependencies: [
                "Primitives",
                "Keystore",
                "Blockchain",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "WalletCoreSwiftProtobuf", package: "WalletCore"),
                .product(name: "WalletCorePrimitives", package: "WalletCore"),
                "Keychain",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SignerTests",
            dependencies: [
                "Signer",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "KeychainTestKit", package: "Keychain"),
            ]
        ),
    ]
)

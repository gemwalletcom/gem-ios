// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keystore",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Keystore",
            targets: ["Keystore"]),
        .library(
            name: "KeystoreTestKit",
            targets: ["KeystoreTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
        .package(url: "https://github.com/gemwalletcom/KeychainAccess", exact: Version(4, 2, 2)),
    ],
    targets: [
        .target(
            name: "Keystore",
            dependencies: [
                "Primitives",
                "Store",
                "WalletCorePrimitives",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "SwiftProtobuf", package: "WalletCore"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Sources"
        ),
        .target(
            name: "KeystoreTestKit",
            dependencies: [
                "Keystore",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "KeystoreTests",
            dependencies: [
                "Keystore",
                "KeystoreTestKit",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ]),
    ]
)

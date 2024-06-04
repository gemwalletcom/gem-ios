// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keystore",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Keystore",
            targets: ["Keystore"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Store", path: "../Store"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
        .package(url: "https://github.com/gemwalletcom/KeychainAccess", exact: Version(4, 2, 2)),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Keystore",
            dependencies: [
                "Primitives",
                "Store",
                .product(name: "WalletCore", package: "WalletCore"),
                "WalletCorePrimitives",
                .product(name: "SwiftProtobuf", package: "WalletCore"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "KeystoreTests",
            dependencies: ["Keystore"]),
    ]
)

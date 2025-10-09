// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Keystore",
    platforms: [.iOS(.v17), .macOS(.v15)],
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
        .package(name: "Formatters", path: "../Formatters"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "Keychain", path: "../Keychain")
    ],
    targets: [
        .target(
            name: "Keystore",
            dependencies: [
                .product(name: "WalletCoreSwiftProtobuf", package: "WalletCore"),
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "WalletCorePrimitives", package: "WalletCore"),
                "Primitives",
                "Formatters",
                "Keychain"
            ],
            path: "Sources"
        ),
        .target(
            name: "KeystoreTestKit",
            dependencies: [
                "Keystore",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "KeystoreTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "KeystoreTestKit",
                "Keystore"
            ]),
    ]
)

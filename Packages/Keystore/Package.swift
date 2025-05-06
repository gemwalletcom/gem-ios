// swift-tools-version: 6.0

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
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
        .package(url: "https://github.com/gemwalletcom/KeychainAccess", exact: Version(4, 2, 2)),
        .package(name: "Gemstone", path: "../../Packages/Gemstone")
    ],
    targets: [
        .target(
            name: "Keystore",
            dependencies: [
                .product(name: "WalletCoreSwiftProtobuf", package: "WalletCore"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "WalletCore", package: "WalletCore"),
                "WalletCorePrimitives",
                "Primitives",
                "Gemstone"
            ],
            path: "Sources"
        ),
        .target(
            name: "KeystoreTestKit",
            dependencies: [
                "Keystore"
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

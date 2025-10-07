// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "Blockchain",
            targets: ["Blockchain"]
        ),
        .library(
            name: "BlockchainTestKit",
            targets: ["BlockchainTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "SwiftHTTPClient", path: "../SwiftHTTPClient"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Formatters", path: "../Formatters"),
        .package(name: "Preferences", path: "../Preferences"),
        .package(name: "Keychain", path: "../Keychain"),
        .package(name: "FeatureServices", path: "../FeatureServices"),
    ],
    targets: [
        .target(
            name: "Blockchain",
            dependencies: [
                "SwiftHTTPClient",
                "Primitives",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "WalletCorePrimitives", package: "WalletCore"),
                "Gemstone",
                "GemstonePrimitives",
                "Formatters",
                "Preferences",
                "Keychain",
                .product(name: "NativeProviderService", package: "FeatureServices"),
            ],
            path: "Sources"
        ),
        .target(
            name: "BlockchainTestKit",
            dependencies: [
                "Blockchain",
                "Primitives",
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "BlockchainTests",
            dependencies: [
                "Blockchain",
                "BlockchainTestKit",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ]
        ),
    ]
)

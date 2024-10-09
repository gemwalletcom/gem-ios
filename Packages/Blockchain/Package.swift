// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Blockchain",
            targets: ["Blockchain"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "SwiftHTTPClient", path: "../SwiftHTTPClient"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "Blockchain",
            dependencies: [
                "SwiftHTTPClient",
                "Primitives",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "SwiftProtobuf", package: "WalletCore"),
                "WalletCorePrimitives",
                "Gemstone",
                "GemstonePrimitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "BlockchainTests",
            dependencies: [
                "Blockchain",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ]),
    ]
)

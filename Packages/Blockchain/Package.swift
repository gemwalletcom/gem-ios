// swift-tools-version: 5.9
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
        .package(url: "https://github.com/gemwalletcom/wallet-core-release", exact: Version(stringLiteral: "4.1.5")),
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
                .product(name: "WalletCore", package: "wallet-core-release"),
                .product(name: "SwiftProtobuf", package: "wallet-core-release"),
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

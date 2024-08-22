// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalletCorePrimitives",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "WalletCorePrimitives",
            targets: ["WalletCorePrimitives"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(url: "https://github.com/gemwalletcom/wallet-core-release", exact: Version(stringLiteral: "4.1.5")),
    ],
    targets: [
        .target(
            name: "WalletCorePrimitives",
            dependencies: [
                "Primitives",
                .product(name: "WalletCore", package: "wallet-core-release"),
                .product(name: "SwiftProtobuf", package: "wallet-core-release"),
            ]
        ),
        .testTarget(
            name: "WalletCorePrimitivesTests",
            dependencies: ["WalletCorePrimitives"]),
    ]
)

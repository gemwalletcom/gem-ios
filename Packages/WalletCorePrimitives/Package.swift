// swift-tools-version: 6.0
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
        .package(name: "WalletCore", path: "../WalletCore"),
    ],
    targets: [
        .target(
            name: "WalletCorePrimitives",
            dependencies: [
                "Primitives",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "SwiftProtobuf", package: "WalletCore"),
            ]
        ),
        .testTarget(
            name: "WalletCorePrimitivesTests",
            dependencies: ["WalletCorePrimitives"]),
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalletCorePrimitives",
    platforms: [.iOS(.v16), .macOS(.v12)],
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
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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

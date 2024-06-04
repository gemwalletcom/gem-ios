// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
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
        .package(name: "GemstoneSwift", path: "../GemstoneSwift"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Blockchain",
            dependencies: [
                "SwiftHTTPClient",
                "Primitives",
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "SwiftProtobuf", package: "WalletCore"),
                "WalletCorePrimitives",
                "Gemstone",
                "GemstoneSwift",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "BlockchainTests",
            dependencies: ["Blockchain"]),
    ]
)

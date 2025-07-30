// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "WalletCore",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(name: "WalletCore", targets: ["WalletCore"]),
        .library(name: "WalletCoreSwiftProtobuf", targets: ["WalletCoreSwiftProtobuf"]),
        .library(name: "WalletCorePrimitives", targets: ["WalletCorePrimitives"])
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives")
    ],
    targets: [
        .binaryTarget(
            name: "WalletCore",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.6/WalletCore.xcframework.zip",
            checksum: "3daaf984438e227bc52958cc77085dbbef4cd9d32b2cb85289c091e0d3a3bb87"
        ),
        .binaryTarget(
            name: "WalletCoreSwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.6/WalletCoreSwiftProtobuf.xcframework.zip",
            checksum: "6896d872919d7cb2b25f7883ba0e31e4faf20b66ff4ef5053c8a93add48f73e0"
        ),
        .target(
            name: "WalletCorePrimitives",
            dependencies: [
                "Primitives",
                "WalletCore",
                "WalletCoreSwiftProtobuf"
            ]
        ),
        .testTarget(
            name: "WalletCorePrimitivesTests",
            dependencies: [
                "WalletCorePrimitives",
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ]
        )
    ]
)

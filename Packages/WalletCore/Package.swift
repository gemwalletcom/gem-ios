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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.22/WalletCore.xcframework.zip",
            checksum: "f92bc890117606ce6e2f1c0115d470d91dd447e776250325cdfa23fbae3493ca"
        ),
        .binaryTarget(
            name: "WalletCoreSwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.22/WalletCoreSwiftProtobuf.xcframework.zip",
            checksum: "c4ad83da5acec7937112087deec74981ae60291f9ddabddf7095ce46b8262d88"
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

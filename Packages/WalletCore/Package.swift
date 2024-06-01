// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalletCore",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "WalletCore", targets: ["WalletCore"]),
        .library(name: "SwiftProtobuf", targets: ["SwiftProtobuf"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "WalletCore",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.0.42/WalletCore.xcframework.zip",
            checksum: "861b4240995e7166680064d29efa218eecdab5171fc29590586e59ebdf61ce79"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.0.42/SwiftProtobuf.xcframework.zip",
            checksum: "d0b87777d5de3d854b878c632730aa7d993e8912ea35479746f09913b234ae0a"
        )
    ]
)

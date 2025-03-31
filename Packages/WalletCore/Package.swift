// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WalletCore",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "WalletCore", targets: ["WalletCore"]),
        .library(name: "SwiftProtobuf", targets: ["SwiftProtobuf"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "WalletCore",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.2.18/WalletCore.xcframework.zip",
            checksum: "7982fb0e7b5953415407c43ec8657c9cd8602d3d57711cc8a96b4b54a7af6b2b"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.2.18/SwiftProtobuf.xcframework.zip",
            checksum: "2956d554c066dbb99d5de97a4d7c6701652c4379ab4869a84557fec25efe7b6e"
        )
    ]
)

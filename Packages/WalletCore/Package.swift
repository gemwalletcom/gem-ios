// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalletCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "WalletCore", targets: ["WalletCore"]),
        .library(name: "SwiftProtobuf", targets: ["SwiftProtobuf"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "WalletCore",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.1/WalletCore.xcframework.zip",
            checksum: "e38c5835a5a049abbb52604147330c91676c52bea5c7c56477cc5e24019c1308"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.1/SwiftProtobuf.xcframework.zip",
            checksum: "aa9044f253927c21570b08e5987e8e026916297d9fa0fc8c884df7c10428ccf1"
        )
    ]
)

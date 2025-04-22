// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WalletCore",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "WalletCore", targets: ["WalletCore"]),
        .library(name: "WalletCoreSwiftProtobuf", targets: ["WalletCoreSwiftProtobuf"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "WalletCore",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.1/WalletCore.xcframework.zip",
            checksum: "bf00f28d898d5e82c217616351d04c87d08384b71c59f40fe8ede753c0494fb1"
        ),
        .binaryTarget(
            name: "WalletCoreSwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.1/WalletCoreSwiftProtobuf.xcframework.zip",
            checksum: "a00ec8771212872e5d6555813c4f3cbb9476edb72a046d4d7bd2f591baf02dfa"
        )
    ]
)

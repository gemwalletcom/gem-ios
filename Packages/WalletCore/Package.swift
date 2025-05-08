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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.3/WalletCore.xcframework.zip",
            checksum: "e1eed5e239e681adeeb06733acaab50df38a72bd6e878acdb00a1cdea793c1ef"
        ),
        .binaryTarget(
            name: "WalletCoreSwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.3/WalletCoreSwiftProtobuf.xcframework.zip",
            checksum: "e2eb34828968964d6a91be8a507e70a3dd624cce1c41280dda1c84151ef74e48"
        )
    ]
)

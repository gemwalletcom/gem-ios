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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.4/WalletCore.xcframework.zip",
            checksum: "71b8ab9fa41a3b3a28527e26b8613ed7fb645558136cfbaabf4b7a479a04b971"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.4/SwiftProtobuf.xcframework.zip",
            checksum: "5b0e7c4d8013b88bfb55cf4236ae19fd64f2f6817a6f7695ed05fa6de2b7536b"
        )
    ]
)

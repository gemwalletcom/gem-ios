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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.19/WalletCore.xcframework.zip",
            checksum: "a05d5084f89e664086f529b2fcf33c34d710a2f5a3000ad5523e489aa4ebacb4"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.19/SwiftProtobuf.xcframework.zip",
            checksum: "6b91a1fa175ae447af54c0c7d6a61c20920d459352269641049b72ad9e567593"
        )
    ]
)

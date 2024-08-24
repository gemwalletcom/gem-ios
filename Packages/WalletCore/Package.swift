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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.5/WalletCore.xcframework.zip",
            checksum: "4b2c1f7386d6d31aa7a7b573bdeb1106dedd3d9989c2b3e8b69579a82aeaab78"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.1.5/SwiftProtobuf.xcframework.zip",
            checksum: "9d2faa98ac5d9f107be1f0d0ebaabde051a0828c20f2fbc840049e5ff7e2131c"
        )
    ]
)

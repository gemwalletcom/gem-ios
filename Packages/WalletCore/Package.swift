// swift-tools-version: 5.9

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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.2.10/WalletCore.xcframework.zip",
            checksum: "83e59b65bb1c600bd5338a9e6e63f2b7fba3adc65d68520a5a1c795eef8030de"
        ),
        .binaryTarget(
            name: "SwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.2.10/SwiftProtobuf.xcframework.zip",
            checksum: "a7c78bc5cd3a0e380124c459c2ab203f80cea44ee1c403dd011f4d56df412161"
        )
    ]
)

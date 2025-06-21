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
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.5/WalletCore.xcframework.zip",
            checksum: "9ed986468f536c31e028fe3e20629f5a492526bfcd9d9e290f34619093db4285"
        ),
        .binaryTarget(
            name: "WalletCoreSwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.3.5/WalletCoreSwiftProtobuf.xcframework.zip",
            checksum: "008dec99c8768f9c1d07752880bce8faa48f9aa7fa2a7a06b68a4ce6566d7424"
        )
    ]
)

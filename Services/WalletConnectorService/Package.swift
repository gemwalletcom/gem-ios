// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletConnectorService",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "WalletConnectorService",
            targets: ["WalletConnectorService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(url: "https://github.com/gemwalletcom/reown-swift.git", revision: "855afee0b3764675051cdb9c905b91d461e5f5a6"),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: Version(stringLiteral: "3.1.2")),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
    ],
    targets: [
        .target(
            name: "WalletConnectorService",
            dependencies: [
                "Primitives",
                "Gemstone",
                "GemstonePrimitives",
                .product(
                    name: "WalletConnect",
                    package: "reown-swift"
                ),
                .product(
                    name: "ReownWalletKit",
                    package: "reown-swift"
                ),
                .product(name: "Starscream", package: "Starscream"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletConnectorServiceTests",
            dependencies: ["WalletConnectorService"]
        ),
    ]
)

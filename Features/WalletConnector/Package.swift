// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WalletConnector",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "WalletConnector",
            targets: ["WalletConnector"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "WalletConnectorService", path: "../WalletConnectorService"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Store", path: "../Store"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "QRScanner", path: "../QRScanner"),
    ],
    targets: [
        .target(
            name: "WalletConnector",
            dependencies: [
                "Primitives",
                "WalletConnectorService",
                "Components",
                "Localization",
                "Style",
                "Store",
                "Keystore",
                "PrimitivesComponents",
                "QRScanner"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "WalletConnectorTests",
            dependencies: ["WalletConnector"]
        ),
    ]
)

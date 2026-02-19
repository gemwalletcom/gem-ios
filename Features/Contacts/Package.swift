// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Contacts",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "Contacts",
            targets: ["Contacts"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Validators", path: "../../Packages/Validators"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "QRScanner", path: "../../Packages/QRScanner"),
        .package(name: "WalletCore", path: "../../Packages/WalletCore"),
    ],
    targets: [
        .target(
            name: "Contacts",
            dependencies: [
                "Primitives",
                "PrimitivesComponents",
                "Components",
                "Localization",
                "Style",
                "Store",
                "Validators",
                "Formatters",
                "GemstonePrimitives",
                "QRScanner",
                .product(name: "ContactService", package: "FeatureServices"),
                .product(name: "WalletCorePrimitives", package: "WalletCore"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ContactsTests",
            dependencies: [
                "Contacts",
                "Primitives",
                "PrimitivesComponents",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "ContactService", package: "FeatureServices"),
            ]
        ),
    ]
)

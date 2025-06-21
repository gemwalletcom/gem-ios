// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Swap",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Swap",
            targets: ["Swap"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "SwapService", path: "../../Services/SwapService"),
        .package(name: "Signer", path: "../../Packages/Signer"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "WalletsService", path: "../../Services/WalletsService"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "InfoSheet", path: "../InfoSheet")
    ],
    targets: [
        .target(
            name: "Swap",
            dependencies: [
                "Primitives",
                "Formatters",
                "Components",
                "GemstonePrimitives",
                "Gemstone",
                "Localization",
                "SwapService",
                "Signer",
                "Keystore",
                "Store",
                "Preferences",
                "WalletsService",
                "PrimitivesComponents",
                "InfoSheet"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SwapTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletsServiceTestKit", package: "WalletsService"),
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "SwapServiceTestKit", package: "SwapService"),
                "Swap"
            ]
        )
    ]
)

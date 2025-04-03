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
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "SwapService", path: "../../Services/SwapService"),
        .package(name: "Signer", path: "../../Packages/Signer"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
    ],
    targets: [
        .target(
            name: "Swap",
            dependencies: [
                "Primitives",
                "Components",
                "GemstonePrimitives",
                "Localization",
                "SwapService",
                "Signer",
                "Keystore"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SwapTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "Swap"
            ]
        )
    ]
)

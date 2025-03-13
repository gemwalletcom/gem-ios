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
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "SwapService", path: "../../Services/SwapService"),
        .package(name: "Signer", path: "../Signer"),
        .package(name: "Keystore", path: "../Keystore"),
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

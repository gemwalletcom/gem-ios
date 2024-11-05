// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwapService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwapService",
            targets: ["SwapService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Signer", path: "../Signer"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(name: "NativeProviderService", path: "../NativeProviderService"),
    ],
    targets: [
        .target(
            name: "SwapService",
            dependencies: [
                "Gemstone",
                "GemstonePrimitives",
                "Primitives",
                "ChainService",
                "Signer",
                "NativeProviderService",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SwapServiceTests",
            dependencies: ["SwapService"]
        ),
    ]
)

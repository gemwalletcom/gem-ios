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
        .library(
            name: "SwapServiceTestKit",
            targets: ["SwapServiceTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Signer", path: "../../Packages/Signer"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
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
                "Keystore",
                "NativeProviderService",
            ],
            path: "Sources"
        ),
        .target(
            name: "SwapServiceTestKit",
            dependencies: [
                .product(name: "ChainServiceTestKit", package: "ChainService"),
                "SwapService",
                "Gemstone"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "SwapServiceTests",
            dependencies: ["SwapService"]
        ),
    ]
)

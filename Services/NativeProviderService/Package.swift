// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NativeProviderService",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "NativeProviderService",
            targets: ["NativeProviderService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "ChainService", path: "../ChainService"),
    ],
    targets: [
        .target(
            name: "NativeProviderService",
            dependencies: [
                "Primitives",
                "Gemstone",
                "ChainService",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NativeProviderServiceTests",
            dependencies: [
                "NativeProviderService",
            ]
        ),
    ]
)

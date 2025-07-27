// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NativeProviderService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "NativeProviderService",
            targets: ["NativeProviderService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "ChainService", path: "../ChainService"),
    ],
    targets: [
        .target(
            name: "NativeProviderService",
            dependencies: [
                "Primitives",
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

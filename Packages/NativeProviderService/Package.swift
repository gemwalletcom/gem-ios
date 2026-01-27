// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NativeProviderService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "NativeProviderService",
            targets: ["NativeProviderService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Gemstone", path: "../Gemstone"),
    ],
    targets: [
        .target(
            name: "NativeProviderService",
            dependencies: [
                "Primitives",
                "Gemstone",
            ],
            path: "Sources"
        ),
    ]
)

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
            targets: ["NativeProviderService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Gemstone", path: "../../Packages/Gemstone"),
        .package(name: "ChainService", path: "../ChainService"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: Version(7, 5, 0))
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
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
    ]
)

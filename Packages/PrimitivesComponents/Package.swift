// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrimitivesComponents",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "PrimitivesComponents",
            targets: ["PrimitivesComponents"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Validators", path: "../Validators"),
        .package(name: "Formatters", path: "../Formatters")
    ],
    targets: [
        .target(
            name: "PrimitivesComponents",
            dependencies: [
                "Primitives",
                "GemstonePrimitives",
                .product(name: "WalletCorePrimitives", package: "WalletCore"),
                "Localization",
                "Components",
                "Style",
                "Validators",
                "Formatters"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PrimitivesComponentsTests",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "PrimitivesComponents",
                "GemstonePrimitives",
            ]
        ),
    ]
)

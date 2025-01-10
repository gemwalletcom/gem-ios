// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrimitivesComponents",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PrimitivesComponents",
            targets: ["PrimitivesComponents"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),

    ],
    targets: [
        .target(
            name: "PrimitivesComponents",
            dependencies: [
                "Primitives",
                "GemstonePrimitives",
                "Localization",
                "Components",
                "Style"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PrimitivesComponentsTests",
            dependencies: ["PrimitivesComponents"]
        ),
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GemstonePrimitives",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "GemstonePrimitives",
            targets: ["GemstonePrimitives"]
        ),
    ],
    dependencies: [
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
    ],
    targets: [
        .target(
            name: "GemstonePrimitives",
            dependencies: [
                "Gemstone",
                "Primitives",
                "WalletCorePrimitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "GemstonePrimitivesTests",
            dependencies: [
                "GemstonePrimitives",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ]
        ),
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GemstonePrimitives",
    platforms: [.iOS(.v17), .macOS(.v12)],
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
            ]
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

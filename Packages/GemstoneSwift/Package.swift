// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GemstoneSwift",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "GemstoneSwift",
            targets: ["GemstoneSwift"]
        ),
    ],
    dependencies: [
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives"),
    ],
    targets: [
        .target(
            name: "GemstoneSwift",
            dependencies: [
                "Gemstone",
                "Primitives",
                "WalletCorePrimitives",
            ]
        ),
        .testTarget(
            name: "GemstoneSwiftTests",
            dependencies: ["GemstoneSwift"]
        ),
    ]
)

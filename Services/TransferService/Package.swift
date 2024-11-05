// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TransferService",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "TransferService",
            targets: ["TransferService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Gemstone", path: "../Gemstone"),
    ],
    targets: [
        .target(
            name: "TransferService",
            dependencies: [
                "Primitives",
                "Gemstone",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TransferServiceTests",
            dependencies: ["TransferService"]
        ),
    ]
)
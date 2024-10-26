// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FiatConnect",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "FiatConnect",
            targets: ["FiatConnect"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
    ],
    targets: [
        .target(
            name: "FiatConnect",
            dependencies: [
                "Primitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FiatConnectTests",
            dependencies: [
                "FiatConnect",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        ),
    ]
)

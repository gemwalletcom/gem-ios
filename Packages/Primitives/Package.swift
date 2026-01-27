// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Primitives",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "Primitives",
            targets: ["Primitives"]
        ),
        .library(
            name: "PrimitivesTestKit",
            targets: ["PrimitivesTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "BigInt", path: "../../Submodules/BigInt"),
    ],
    targets: [
        .target(
            name: "Primitives",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
            ],
            path: "Sources"
        ),
        .target(
            name: "PrimitivesTestKit",
            dependencies: [
                "Primitives",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "PrimitivesTests",
            dependencies: [
                "Primitives",
                "PrimitivesTestKit",
            ]
        ),
    ]
)

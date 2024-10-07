// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Primitives",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Primitives",
            targets: ["Primitives"]),
        .library(
            name: "PrimitivesTestKit",
            targets: ["PrimitivesTestKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", exact: Version(5, 4, 1)),
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
            ]),
    ]
)

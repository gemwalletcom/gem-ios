// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Store",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "Store",
            targets: ["Store"]
        ),
        .library(
            name: "StoreTestKit",
            targets: ["StoreTestKit"]
        ),
        .library(
            name: "CloudStore",
            targets: ["CloudStore"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GRDB", path: "../../Submodules/GRDB"),
    ],
    targets: [
        .target(
            name: "Store",
            dependencies: [
                "Primitives",
                .product(name: "GRDB", package: "GRDB"),
            ],
            path: "Sources"
        ),
        .target(
            name: "StoreTestKit",
            dependencies: [
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                "Store",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "StoreTests",
            dependencies: [
                "Store",
                "StoreTestKit",
                "CloudStore",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ]
        ),
        .target(
            name: "CloudStore",
            path: "CloudStore"
        ),
    ]
)

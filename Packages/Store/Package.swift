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
            targets: ["StoreTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GRDB", path: "../../Submodules/GRDB"),
        .package(name: "GRDBQuery", path: "../../Submodules/GRDBQuery"),
    ],
    targets: [
        .target(
            name: "Store",
            dependencies: [
                "Primitives",
                .product(name: "GRDB", package: "GRDB"),
                .product(name: "GRDBQuery", package: "GRDBQuery"),
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
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ]
        ),
    ]
)

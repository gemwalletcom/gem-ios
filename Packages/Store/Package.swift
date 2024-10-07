// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Store",
    platforms: [.iOS(.v17), .macOS(.v12)],
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
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: Version(6, 29, 3)),
        .package(url: "https://github.com/groue/GRDBQuery.git", exact: Version(0, 9, 0)),
        .package(url: "https://github.com/gemwalletcom/KeychainAccess", exact: Version(4, 2, 2)),
    ],
    targets: [
        .target(
            name: "Store",
            dependencies: [
                "Primitives",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "GRDBQuery", package: "GRDBQuery"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Sources"
        ),
        .target(
            name: "StoreTestKit",
            dependencies: [
                "Store",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "StoreTests",
            dependencies: [
                "Store",
                "StoreTestKit",
            ]
        ),
    ]
)

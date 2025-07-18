// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AddressNameService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AddressNameService",
            targets: ["AddressNameService"]),
        .library(
            name: "AddressNameServiceTestKit",
            targets: ["AddressNameServiceTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
    ],
    targets: [
        .target(
            name: "AddressNameService",
            dependencies: [
                "Primitives",
                "Store",
            ],
            path: "Sources"
        ),
        .target(
            name: "AddressNameServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                "Primitives",
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "AddressNameServiceTests",
            dependencies: [
                "AddressNameServiceTestKit"
            ]
        ),
    ]
)

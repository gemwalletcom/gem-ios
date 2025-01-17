// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ExplorerService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ExplorerService",
            targets: ["ExplorerService"]
        ),
    ],
    dependencies: [
        .package(name: "Gemstone", path: "../Gemstone"),
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "GemstonePrimitives", path: "../GemstonePrimitives"),
        .package(name: "Preferences", path: "../Preferences"),
    ],
    targets: [
        .target(
            name: "ExplorerService",
            dependencies: [
                "Primitives",
                "Gemstone",
                "GemstonePrimitives",
                "Preferences"
            ]
        ),
        .testTarget(
            name: "ExplorerServiceTests",
            dependencies: [
                "ExplorerService",
                .product(name: "PreferencesTestKit", package: "Preferences")
            ]
        ),
    ]
)

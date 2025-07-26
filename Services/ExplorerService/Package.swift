// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ExplorerService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "ExplorerService",
            targets: ["ExplorerService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
    ],
    targets: [
        .target(
            name: "ExplorerService",
            dependencies: [
                "Primitives",
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

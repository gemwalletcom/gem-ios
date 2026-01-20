// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Recents",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "Recents",
            targets: ["Recents"]),
        .library(
            name: "RecentsTestKit",
            targets: ["RecentsTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
    ],
    targets: [
        .target(
            name: "Recents",
            dependencies: [
                "Primitives",
                "PrimitivesComponents",
                "Components",
                "Localization",
                "Style",
                "Store",
                .product(name: "ActivityService", package: "FeatureServices"),
            ],
            path: "Sources"
        ),
        .target(
            name: "RecentsTestKit",
            dependencies: [
                "Recents",
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "ActivityServiceTestKit", package: "FeatureServices"),
            ],
            path: "TestKit"
        ),
    ]
)

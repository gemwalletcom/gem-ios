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
            ],
            path: "Sources"
        ),
        .target(
            name: "RecentsTestKit",
            dependencies: [
                "Recents",
            ],
            path: "TestKit"
        ),
    ]
)

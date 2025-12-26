// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EventManager",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "EventManager",
            targets: ["EventManager"]),
        .library(
            name: "EventManagerTestKit",
            targets: ["EventManagerTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "Style", path: "../../Packages/Style"),
    ],
    targets: [
        .target(
            name: "EventManager",
            dependencies: [
                "Primitives",
                "PrimitivesComponents",
                "Components",
                "Localization",
                "Style",
            ],
            path: "Sources"
        ),
        .target(
            name: "EventManagerTestKit",
            dependencies: [
                "EventManager",
            ],
            path: "TestKit"
        ),
    ]
)

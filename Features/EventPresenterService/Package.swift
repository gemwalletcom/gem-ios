// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EventPresenterService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "EventPresenterService",
            targets: ["EventPresenterService"]),
        .library(
            name: "EventPresenterServiceTestKit",
            targets: ["EventPresenterServiceTestKit"]),
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
            name: "EventPresenterService",
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
            name: "EventPresenterServiceTestKit",
            dependencies: [
                "EventPresenterService",
            ],
            path: "TestKit"
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Perpetuals",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Perpetuals",
            targets: ["Perpetuals"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PerpetualService", path: "../../Services/PerpetualService"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "InfoSheet", path: "../InfoSheet"),
    ],
    targets: [
        .target(
            name: "Perpetuals",
            dependencies: [
                "Primitives",
                "PrimitivesComponents",
                "Components",
                "Style",
                "Localization",
                "PerpetualService",
                "Store",
                "Formatters",
                "Preferences",
                "InfoSheet",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PerpetualsTests",
            dependencies: [
                "Perpetuals",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

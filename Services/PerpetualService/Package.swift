// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PerpetualService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "PerpetualService",
            targets: ["PerpetualService"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Blockchain", path: "../../Packages/Blockchain"),
        .package(name: "ChainService", path: "../../Services/ChainService"),
    ],
    targets: [
        .target(
            name: "PerpetualService",
            dependencies: [
                "Primitives",
                "Store",
                "Blockchain",
                "ChainService",
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageModes: [.v6]
)

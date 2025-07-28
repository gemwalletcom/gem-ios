// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScanService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "ScanService",
            targets: ["ScanService"]),
        .library(
            name: "ScanServiceTestKit",
            targets: ["ScanServiceTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "GemAPI", path: "../../Packages/GemAPI"),
    ],
    targets: [
        .target(
            name: "ScanService",
            dependencies: [
                "Primitives",
                "GemAPI",
            ],
            path: "Sources"
        ),
        .target(
            name: "ScanServiceTestKit",
            dependencies: [
                "ScanService",
                "Primitives",
                "GemAPI",
            ],
            path: "TestKit"
        ),
    ]
)

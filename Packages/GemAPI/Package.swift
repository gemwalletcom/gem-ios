// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GemAPI",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "GemAPI",
            targets: ["GemAPI"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "SwiftHTTPClient", path: "../SwiftHTTPClient"),
    ],
    targets: [
        .target(
            name: "GemAPI",
            dependencies: [
                "Primitives",
                "SwiftHTTPClient",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "GemAPITests",
            dependencies: ["GemAPI"]),
    ]
)

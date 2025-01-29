// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "XLog",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "XLog",
            targets: ["XLog"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XLog",
            dependencies: [],
            path: "Sources"
        )
    ]
)

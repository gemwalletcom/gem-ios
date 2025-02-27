// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FileStore",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "FileStore",
            targets: ["FileStore"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FileStore",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "FileStoreTests",
            dependencies: ["FileStore"]),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SystemServices",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "ImageGalleryService", targets: ["ImageGalleryService"]),
        .library(name: "CloudStore", targets: ["CloudStore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ImageGalleryService",
            dependencies: [],
            path: "ImageGalleryService",
            exclude: ["Tests", "TestKit"]
        ),
        .target(
            name: "CloudStore",
            dependencies: [],
            path: "CloudStore"
        )
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ImageGalleryService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ImageGalleryService",
            targets: ["ImageGalleryService"]),
    ],
    targets: [
        .target(
            name: "ImageGalleryService",
            dependencies: [],
            path: "Sources"
        )
    ]
)

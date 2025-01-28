// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ImageSaverService",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ImageSaverService",
            targets: ["ImageSaverService"]),
    ],
    targets: [
        .target(
            name: "ImageSaverService",
            dependencies: [],
            path: "Sources"
        )
    ]
)

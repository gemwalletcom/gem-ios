// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JobRunner",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "JobRunner",
            targets: ["JobRunner"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "JobRunner",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "JobRunnerTests",
            dependencies: ["JobRunner"]
        ),
    ]
)

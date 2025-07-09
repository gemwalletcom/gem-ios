// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JobRunner",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "JobRunner",
            targets: ["JobRunner"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives")
    ],
    targets: [
        .target(
            name: "JobRunner",
            dependencies: [
                "Primitives"
            ]
        ),
        .testTarget(
            name: "JobRunnerTests",
            dependencies: ["JobRunner"]
        ),
    ]
)

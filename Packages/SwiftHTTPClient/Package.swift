// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftHTTPClient",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "SwiftHTTPClient",
            targets: ["SwiftHTTPClient"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftHTTPClient",
            dependencies: [], path: "Sources"
        ),
        .testTarget(
            name: "SwiftHTTPClientTests",
            dependencies: ["SwiftHTTPClient"]),
    ]
)

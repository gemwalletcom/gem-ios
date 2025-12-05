// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftHTTPClient",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "SwiftHTTPClient",
            targets: ["SwiftHTTPClient"]
        ),
        .library(
            name: "SwiftHTTPClientTestKit",
            targets: ["SwiftHTTPClientTestKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftHTTPClient",
            dependencies: [],
            path: "Sources"
        ),
        .target(
            name: "SwiftHTTPClientTestKit",
            dependencies: ["SwiftHTTPClient"],
            path: "TestKit"
        ),
        .testTarget(
            name: "SwiftHTTPClientTests",
            dependencies: ["SwiftHTTPClient"]
        ),
    ]
)

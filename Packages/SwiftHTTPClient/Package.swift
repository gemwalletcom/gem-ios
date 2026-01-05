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
        .library(
            name: "WebSocketClient",
            targets: ["WebSocketClient"]
        ),
        .library(
            name: "WebSocketClientTestKit",
            targets: ["WebSocketClientTestKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftHTTPClient",
            dependencies: [],
            path: "SwiftHTTPClient",
            exclude: ["TestKit", "Tests"]
        ),
        .target(
            name: "SwiftHTTPClientTestKit",
            dependencies: ["SwiftHTTPClient"],
            path: "SwiftHTTPClient/TestKit"
        ),
        .testTarget(
            name: "SwiftHTTPClientTests",
            dependencies: ["SwiftHTTPClient"],
            path: "SwiftHTTPClient/Tests"
        ),
        .target(
            name: "WebSocketClient",
            dependencies: [],
            path: "WebSocketClient",
            exclude: ["TestKit", "Tests"]
        ),
        .target(
            name: "WebSocketClientTestKit",
            dependencies: ["WebSocketClient"],
            path: "WebSocketClient/TestKit"
        ),
        .testTarget(
            name: "WebSocketClientTests",
            dependencies: ["WebSocketClient"],
            path: "WebSocketClient/Tests"
        ),
    ]
)

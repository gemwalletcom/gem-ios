// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WebSocketClient",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
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
            name: "WebSocketClient",
            dependencies: [],
            path: "Sources"
        ),
        .target(
            name: "WebSocketClientTestKit",
            dependencies: ["WebSocketClient"],
            path: "TestKit"
        ),
    ]
)

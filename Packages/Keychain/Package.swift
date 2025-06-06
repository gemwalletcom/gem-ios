// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "Keychain",
            targets: ["Keychain"]
        ),
        .library(
            name: "KeychainTestKit",
            targets: ["KeychainTestKit"]
        )
    ],
    targets: [
        .target(
            name: "Keychain",
            path: "Sources"
        ),
        .target(
            name: "KeychainTestKit",
            dependencies: ["Keychain"],
            path: "TestKit"
        ),
        .testTarget(
            name: "KeychainTests",
            dependencies: [
                "Keychain"
            ],
            path: "Tests"
        ),
    ]
)

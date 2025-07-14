// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Preferences",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Preferences",
            targets: ["Preferences"]),
        .library(
            name: "PreferencesTestKit",
            targets: ["PreferencesTestKit"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Keychain", path: "../Keychain")
    ],
    targets: [
        .target(
            name: "Preferences",
            dependencies: [
                "Primitives",
                "Keychain"
            ],
            path: "Sources"
        ),
        .target(
            name: "PreferencesTestKit",
            dependencies: [
                "Primitives",
                "Preferences"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "PreferencesTest",
            dependencies: [
                "Preferences",
                "PreferencesTestKit",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        )
    ]
)

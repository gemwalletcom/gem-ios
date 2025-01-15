// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Preferences",
    platforms: [
        .iOS(.v17),
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
        .package(url: "https://github.com/gemwalletcom/KeychainAccess", exact: Version(4, 2, 2))
    ],
    targets: [
        .target(
            name: "Preferences",
            dependencies: [
                "Primitives",
                .product(name: "KeychainAccess", package: "KeychainAccess"),
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
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Tests"
        )
    ]
)

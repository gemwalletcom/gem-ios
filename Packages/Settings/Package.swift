// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Settings",
            targets: ["Settings"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Settings",
            dependencies: [
                "Primitives",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]),
    ]
)

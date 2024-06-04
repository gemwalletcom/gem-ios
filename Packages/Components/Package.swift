// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Components",
            targets: ["Components"]),
    ],
    dependencies: [
        .package(name: "Style", path: "../Style"),
        .package(url: "https://github.com/gemwalletcom/AlertToast.git", exact: Version(1, 3, 9))
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                "Style",
                .product(name: "AlertToast", package: "AlertToast")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"]),
    ]
)

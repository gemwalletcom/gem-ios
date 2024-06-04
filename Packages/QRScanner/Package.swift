// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRScanner",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "QRScanner",
            targets: ["QRScanner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gemwalletcom/CodeScanner", exact: Version(2, 3, 2)),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "QRScanner",
            dependencies: [
                .product(name: "CodeScanner", package: "CodeScanner"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "QRScannerTests",
            dependencies: ["QRScanner"]),
    ]
)

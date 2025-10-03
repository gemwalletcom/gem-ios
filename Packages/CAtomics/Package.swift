// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CAtomics",
    products: [
        .library(name: "CAtomics", targets: ["CAtomics"])
    ],
    targets: [
        .target(
            name: "CAtomics",
            path: "Sources",
            publicHeadersPath: "include"
        )
    ]
)

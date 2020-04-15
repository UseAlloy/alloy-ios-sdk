// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Alloy",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "Alloy",
            targets: ["Alloy"]),
    ],
    targets: [
        .target(
            name: "Alloy",
            path: "Alloy"),
    ],
    swiftLanguageVersions: [
        .v4_2,
    ]
)

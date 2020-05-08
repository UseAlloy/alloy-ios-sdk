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
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "3.1.8"),
    ],
    targets: [
        .target(
            name: "Alloy",
            dependencies: ["Lottie"],
            path: "Alloy")
    ],
    swiftLanguageVersions: [
        .v4_2,
    ]
)

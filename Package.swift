// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Middleman",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Middleman",
            targets: ["Middleman"]
        ),
        .executable(
            name: "MiddlemanCLI",
            targets: ["MiddlemanCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.6"),
		.package(url: "https://github.com/ValentinWalter/StringCase", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Middleman",
            dependencies: ["StringCase"]
        ),
        .executableTarget(
            name: "MiddlemanCLI",
            dependencies: [
                .target(name: "Middleman"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "MiddlemanTests",
            dependencies: ["Middleman"]
        ),
    ]
)

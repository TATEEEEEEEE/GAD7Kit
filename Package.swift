// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "GAD7Kit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GAD7Kit",
            targets: ["GAD7Kit"]
        )
    ],
    targets: [
        .target(
            name: "GAD7Kit",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        ),
        .testTarget(
            name: "GAD7KitTests",
            dependencies: ["GAD7Kit"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        )
    ]
)

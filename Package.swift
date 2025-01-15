// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Rudder",
    platforms: [
        .iOS(.v12), .tvOS(.v11), .watchOS("7.0")
    ],
    products: [
        .library(
            name: "Rudder",
            targets: ["Rudder"]
        )
    ],
    dependencies: [
        .package(name: "MetricsReporter", url: "https://github.com/rudderlabs/metrics-reporter-ios", .exact("2.0.0")),
        .package(name: "BrazeKit", url: "https://github.com/braze-inc/braze-swift-sdk", .exact("11.3.0")),
    ],
    targets: [
        .target(
            name: "Rudder",
            dependencies: [
                .product(name: "MetricsReporter", package: "MetricsReporter"),
                .product(name: "BrazeKit", package: "BrazeKit"),
            ],
            path: "Sources",
            sources: ["Classes/"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ],
            publicHeadersPath: "Classes/Headers/Public/",
            cSettings: [
                .headerSearchPath("Classes/Headers/")
            ]
        ),
        .testTarget(
            name: "RudderTests",
            dependencies: ["Rudder", "MetricsReporter", "BrazeKit"],
            path: "Tests"
        ),
    ]
)

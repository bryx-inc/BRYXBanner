// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "BRYXBanner",
    platforms: [
        .ios(.v8),
    ],
    products: [
        .library(name: "BRYXBanner", targets: ["BRYXBanner"])
    ],
    dependencies: [],
    targets: [
        .target(name: "BRYXBanner", path: "Pod", sources: ["Classes"])
    ]
)

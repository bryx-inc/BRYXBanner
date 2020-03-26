// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "TAP2SalesBanner",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "TAP2SalesBanner",
            targets: ["TAP2SalesBanner"]),
    ],
    dependencies: [
        // no dependencies
    ],
    targets: [
        .target(
            name: "TAP2SalesBanner",
            dependencies: []),
        .testTarget(
            name: "TAP2SalesBannerTests",
            dependencies: ["TAP2SalesBanner"]),
    ]
)

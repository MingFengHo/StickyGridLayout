// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "StickyGridLayout",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS(.v10_13) // for building/testing the UIKit-free GridGeometry core
    ],
    products: [
        .library(name: "StickyGridLayout", targets: ["StickyGridLayout"]),
    ],
    targets: [
        .target(name: "StickyGridLayout"),
        .testTarget(name: "StickyGridLayoutTests", dependencies: ["StickyGridLayout"]),
    ]
)

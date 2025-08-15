// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TeatroAppleBridge",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "TeatroAppleBridge", targets: ["TeatroAppleBridge"])
    ],
    targets: [
        .target(name: "TeatroAppleBridge"),
        .testTarget(name: "TeatroAppleBridgeTests", dependencies: ["TeatroAppleBridge"])
    ]
)

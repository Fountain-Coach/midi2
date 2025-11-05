// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MIDI2BridgeAUCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "MIDI2BridgeAUCore", targets: ["MIDI2BridgeAUCore"])
    ],
    dependencies: [
        .package(path: "../TeatroAppleBridge")
    ],
    targets: [
        .target(
            name: "MIDI2BridgeAUCore",
            dependencies: [
                .product(name: "TeatroAppleBridge", package: "TeatroAppleBridge")
            ]
        )
    ]
)


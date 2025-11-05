// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IOBridgeDemo",
    platforms: [ .macOS(.v13), .iOS(.v16) ],
    dependencies: [
        .package(path: "../../Packages/TeatroAppleBridge")
    ],
    targets: [
        .executableTarget(
            name: "IOBridgeDemo",
            dependencies: [
                .product(name: "TeatroAppleBridge", package: "TeatroAppleBridge")
            ])
    ]
)


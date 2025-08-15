// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VirtualSourceDemo",
    platforms: [ .macOS(.v13) ],
    dependencies: [
        .package(path: "../../Packages/TeatroAppleBridge")
    ],
    targets: [
        .executableTarget(
            name: "VirtualSourceDemo",
            dependencies: [
                .product(name: "TeatroAppleBridge", package: "TeatroAppleBridge")
            ])
    ]
)

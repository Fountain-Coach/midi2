// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SendCCDemo",
    platforms: [ .macOS(.v13) ],
    dependencies: [
        .package(path: "../../Packages/TeatroAppleBridge")
    ],
    targets: [
        .executableTarget(
            name: "SendCCDemo",
            dependencies: [
                .product(name: "TeatroAppleBridge", package: "TeatroAppleBridge")
            ])
    ]
)

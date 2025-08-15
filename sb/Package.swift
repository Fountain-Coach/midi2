// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SemanticBrowser",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "sb", targets: ["SBCLI"]),
        .library(name: "SBCore", targets: ["SBCore"])
    ],
    dependencies: [],
    targets: [
        .target(name: "SBCore", path: "Sources/SBCore"),
        .executableTarget(name: "SBCLI", dependencies: ["SBCore"], path: "Sources/SBCLI"),
        .testTarget(name: "SBTests", dependencies: ["SBCore"], path: "Tests/SBTests")
    ]
)

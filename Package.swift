// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MIDI2",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "MIDI2", targets: ["MIDI2"]),
        .library(name: "MIDI2CI", targets: ["MIDI2CI"]),
        .executable(name: "midi2demo", targets: ["midi2demo"])
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .target(name: "MIDI2"),
        .target(name: "MIDI2CI", dependencies: ["MIDI2"]),
        .executableTarget(name: "midi2demo", dependencies: [
            "MIDI2",
            "MIDI2CI",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),
        .testTarget(name: "MIDI2Tests", dependencies: ["MIDI2", "MIDI2CI"]),
        .testTarget(name: "Fuzz", dependencies: ["MIDI2", "SwiftCheck"], path: "Tests/Fuzz")
    ]
)

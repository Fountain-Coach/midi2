// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MIDI2",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "MIDI2", targets: ["MIDI2"]),
        .library(name: "MIDI2CI", targets: ["MIDI2CI"])
    ],
    targets: [
        .target(name: "MIDI2"),
        .target(name: "MIDI2CI", dependencies: ["MIDI2"]),
        .testTarget(name: "MIDI2Tests", dependencies: ["MIDI2", "MIDI2CI"])
    ]
)

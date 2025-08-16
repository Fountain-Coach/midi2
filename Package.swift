// swift-tools-version: 6.1
import PackageDescription

let packageVersion = "0.3.0"

let package = Package(
    name: "MIDI2",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "MIDI2", targets: ["MIDI2"]),
        .library(name: "MIDI2CI", targets: ["MIDI2CI"]),
        .executable(name: "midi2demo", targets: ["midi2demo"]),
        .executable(name: "jitterdemo", targets: ["jitterdemo"])
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1")
    ],
    targets: [
        .target(name: "MIDI2"),
        .target(name: "MIDI2CI", dependencies: ["MIDI2"]),
        .executableTarget(
            name: "midi2demo",
            dependencies: [
                "MIDI2",
                "MIDI2CI",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                .copy("midi2demo.1")
            ]
        ),
        .executableTarget(
            name: "jitterdemo",
            dependencies: ["MIDI2"],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend", "-strict-concurrency=complete",
                    "-Xfrontend", "-enable-actor-data-race-checks",
                    "-Xfrontend", "-warn-concurrency"
                ], .when(configuration: .debug))
            ]
        ),
        .testTarget(name: "MIDI2Tests", dependencies: ["MIDI2", "MIDI2CI", "midi2demo"]),
        .testTarget(name: "Fuzz", dependencies: ["MIDI2", "SwiftCheck"], path: "Tests/Fuzz")
    ]
)

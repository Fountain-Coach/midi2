// swift-tools-version: 6.1
import PackageDescription

let packageVersion = "0.9.2"

let package = Package(
    name: "MIDI2",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "MIDI2", targets: ["MIDI2"]),
        .library(name: "MIDI2CI", targets: ["MIDI2CI"]),
        .executable(name: "midi2demo", targets: ["midi2demo"]),
        .executable(name: "jitterdemo", targets: ["jitterdemo"]),
        .executable(name: "midi2compliance", targets: ["midi2compliance"]),
        .executable(name: "midi2umpd", targets: ["midi2umpd"])
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "MIDI2", dependencies: [.product(name: "Numerics", package: "swift-numerics")]),
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
        .executableTarget(
            name: "midi2device",
            dependencies: ["MIDI2", "MIDI2CI"]
        ),
        // ALSA C shim target for Linux
        .target(
            name: "UMPALSA",
            path: "Sources/UMPALSA",
            publicHeadersPath: ".",
            cSettings: [
                .define("USE_ALSA", to: "1", .when(platforms: [.linux]))
            ],
            linkerSettings: [
                .linkedLibrary("asound", .when(platforms: [.linux]))
            ]
        ),
        .executableTarget(
            name: "midi2compliance",
            dependencies: ["MIDI2", "MIDI2CI"]
        ),
        .executableTarget(
            name: "midi2umpd",
            dependencies: ["MIDI2", "MIDI2CI", "UMPALSA"],
            swiftSettings: [
                .define("LINUX", .when(platforms: [.linux]))
            ]
        ),
        .testTarget(name: "MIDI2Tests", dependencies: ["MIDI2", "MIDI2CI", "midi2demo"]),
        .testTarget(name: "Fuzz", dependencies: ["MIDI2", "SwiftCheck"], path: "Tests/Fuzz")
    ]
)

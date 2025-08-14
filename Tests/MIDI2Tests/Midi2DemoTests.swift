import XCTest
import Foundation

final class Midi2DemoTests: XCTestCase {
    private func run(_ arguments: [String]) throws -> (stdout: String, stderr: String, status: Int32) {
        let executable = productsDirectory.appendingPathComponent("midi2demo")
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        try process.run()
        process.waitUntilExit()
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        return (stdout, stderr, process.terminationStatus)
    }

    private var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    func testNoteOnSuccess() throws {
        let result = try run(["note-on", "--group", "0", "--channel", "0", "60", "100"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("UMP: 0x40903C00 0x00640000"))
        XCTAssertTrue(result.stdout.contains("Decoded -> group: 0 channel: 0 note: 60 velocity: 100"))
        XCTAssertEqual(result.stderr, "")
    }

    func testNoteOnInvalidGroup() throws {
        let result = try run(["note-on", "--group", "16", "--channel", "0", "60", "100"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Group, channel, or note out of range"))
    }

    func testSysEx7Success() throws {
        let result = try run(["sysex7", "--group", "0", "--manufacturer", "7D", "01 02 03"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("Round-trip OK"))
        XCTAssertEqual(result.stderr, "")
    }

    func testSysEx7InvalidManufacturer() throws {
        let result = try run(["sysex7", "--manufacturer", "GG", "00"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Invalid manufacturer ID"))
    }

    func testSysEx8Success() throws {
        let result = try run(["sysex8", "--group", "0", "--manufacturer", "00,20,33", "01 02 03 04"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("Round-trip OK"))
        XCTAssertEqual(result.stderr, "")
    }

    func testSysEx8GroupOutOfRange() throws {
        let result = try run(["sysex8", "--group", "16", "--manufacturer", "00", "01"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Group out of range"))
    }

    func testFlexTempoSuccess() throws {
        let result = try run(["flex", "tempo", "--group", "0", "120"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("Decoded -> BPM: 120.0"))
        XCTAssertEqual(result.stderr, "")
    }

    func testFlexTempoBelowMinimum() throws {
        let result = try run(["flex", "tempo", "--group", "0", "0"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Tempo must be at least 1 BPM"))
    }

    func testFlexTimeSignatureSuccess() throws {
        let result = try run(["flex", "time", "--group", "0", "4", "4"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("meter: 4/4"))
        XCTAssertEqual(result.stderr, "")
    }

    func testFlexTimeSignatureBadDenominator() throws {
        let result = try run(["flex", "time", "--group", "0", "4", "3"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Denominator must be power of two"))
    }

    func testFlexKeySuccess() throws {
        let result = try run(["flex", "key", "--group", "0", "C#m"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("key: C#m"))
        XCTAssertEqual(result.stderr, "")
    }

    func testFlexKeyEmpty() throws {
        let result = try run(["flex", "key", "--group", "0", ""])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Key signature cannot be empty"))
    }

    func testFlexLyricSuccess() throws {
        let result = try run(["flex", "lyric", "--group", "0", "Hello world"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("lyric: Hello world"))
        XCTAssertEqual(result.stderr, "")
    }

    func testFlexLyricEmpty() throws {
        let result = try run(["flex", "lyric", "--group", "0", ""])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Lyric text cannot be empty"))
    }

    func testCIHandshakeSuccess() throws {
        let result = try run(["ci-handshake"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("Agreed protocol: midi2"))
        XCTAssertEqual(result.stderr, "")
    }

    func testCIHandshakeUnknownOption() throws {
        let result = try run(["ci-handshake", "--foo"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Unknown option"))
    }

    func testInspectSuccess() throws {
        let result = try run(["inspect", "0x40903C00", "0x00640000"])
        XCTAssertEqual(result.status, 0)
        XCTAssertTrue(result.stdout.contains("noteOn"))
        XCTAssertEqual(result.stderr, "")
    }

    func testInspectInvalidWord() throws {
        let result = try run(["inspect", "ZZ"])
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(result.stderr.contains("Hex words must be 8 or 16 digits"))
    }
}


#if canImport(Darwin)
import Darwin
import XCTest
@testable import MIDI2Transports

final class RTPMidiSessionDescriptorTests: XCTestCase {
    func testSessionAdoptsPreboundUDPDescriptorWithoutRebinding() throws {
        let listenerDescriptor = socket(AF_INET, SOCK_DGRAM, 0)
        XCTAssertGreaterThanOrEqual(listenerDescriptor, 0)

        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = 0
        address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
        let bindResult = withUnsafeMutablePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.bind(listenerDescriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        XCTAssertEqual(bindResult, 0)

        var length = socklen_t(MemoryLayout<sockaddr_in>.size)
        XCTAssertEqual(withUnsafeMutablePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.getsockname(listenerDescriptor, $0, &length)
            }
        }, 0)
        let port = UInt16(bigEndian: address.sin_port)

        let received = expectation(description: "prebound descriptor receives one RTP-MIDI envelope")
        let expectedWords: [UInt32] = [0x5D00_0001, 0x0000_0002, 0x0000_0003, 0x0000_0004]
        let session = RTPMidiSession(
            localName: "descriptor-test",
            listenPort: port,
            listenDescriptor: listenerDescriptor)
        session.onReceiveUMP = { words in
            XCTAssertEqual(words, expectedWords)
            received.fulfill()
        }
        try session.open()
        try session.waitUntilReady()

        let sender = socket(AF_INET, SOCK_DGRAM, 0)
        XCTAssertGreaterThanOrEqual(sender, 0)
        defer { _ = Darwin.close(sender) }
        var payload = Data(repeating: 0, count: 12)
        for word in expectedWords {
            var value = word.bigEndian
            payload.append(Data(bytes: &value, count: MemoryLayout<UInt32>.size))
        }
        let sent = payload.withUnsafeBytes { bytes in
            withUnsafePointer(to: &address) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    Darwin.sendto(sender, bytes.baseAddress, bytes.count, 0, $0,
                                  socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
        }
        XCTAssertEqual(sent, payload.count)
        wait(for: [received], timeout: 2)
        try session.close()
    }
}

#endif

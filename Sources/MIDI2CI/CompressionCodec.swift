import Foundation
import MIDI2

#if canImport(Compression)
import Compression

private func _compress(_ data: Data, operation: compression_stream_operation, algorithm: compression_algorithm) -> Data? {
    let dummy = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
    defer { dummy.deallocate() }
    let dummyConst = UnsafePointer<UInt8>(dummy)
    var stream = compression_stream(dst_ptr: dummy, dst_size: 0, src_ptr: dummyConst, src_size: 0, state: nil)
    var status = compression_stream_init(&stream, operation, algorithm)
    guard status != COMPRESSION_STATUS_ERROR else { return nil }
    defer { compression_stream_destroy(&stream) }

    let bufferSize = 64 * 1024
    let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { dstBuffer.deallocate() }

    return data.withUnsafeBytes { (srcRaw: UnsafeRawBufferPointer) -> Data? in
        guard let srcPtr = srcRaw.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
        stream.src_ptr = srcPtr
        stream.src_size = data.count
        stream.dst_ptr = dstBuffer
        stream.dst_size = bufferSize

        var output = Data()
        let flags: Swift.Int32 = 1 // COMPRESSION_STREAM_FINALIZE

        repeat {
            status = compression_stream_process(&stream, flags)
            switch status {
            case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                let produced = bufferSize - stream.dst_size
                if produced > 0 {
                    output.append(dstBuffer, count: produced)
                }
                stream.dst_ptr = dstBuffer
                stream.dst_size = bufferSize
            default:
                return nil
            }
        } while status == COMPRESSION_STATUS_OK

        return (status == COMPRESSION_STATUS_END) ? output : nil
    }
}

private func zlibCompress(_ data: Data) -> Data? { _compress(data, operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB) }
private func zlibDecompress(_ data: Data) -> Data? { _compress(data, operation: COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB) }

#endif

public enum PropertyExchangeCodec {
    public static func encode(_ bytes: [UInt8], using encoding: MidiCiPropertyExchangeBody.Encoding) -> [UInt8] {
        switch encoding {
        case .json, .binary, .mcoded7:
            return bytes
        case .jsonZlib, .binaryZlib:
            #if canImport(Compression)
            if let out = zlibCompress(Data(bytes)) { return Array(out) }
            #endif
            return bytes
        }
    }

    public static func decode(_ bytes: [UInt8], using encoding: MidiCiPropertyExchangeBody.Encoding) -> [UInt8] {
        switch encoding {
        case .json, .binary, .mcoded7:
            return bytes
        case .jsonZlib, .binaryZlib:
            #if canImport(Compression)
            if let out = zlibDecompress(Data(bytes)) { return Array(out) }
            #endif
            return bytes
        }
    }
}

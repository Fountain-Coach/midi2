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
        case .json, .binary:
            return bytes
        case .mcoded7:
            return encode7Bit(bytes)
        case .jsonZlib, .binaryZlib:
            #if canImport(Compression)
            if let out = zlibCompress(Data(bytes)) { return Array(out) }
            #endif
            return bytes
        }
    }

    public static func decode(_ bytes: [UInt8], using encoding: MidiCiPropertyExchangeBody.Encoding) -> [UInt8] {
        switch encoding {
        case .json, .binary:
            return bytes
        case .mcoded7:
            return decode7Bit(bytes)
        case .jsonZlib, .binaryZlib:
            #if canImport(Compression)
            if let out = zlibDecompress(Data(bytes)) { return Array(out) }
            #endif
            return bytes
        }
    }

    // Pack arbitrary bytes into 7-bit-safe representation (blocks of up to 7 bytes).
    static func encode7Bit(_ input: [UInt8]) -> [UInt8] {
        var out: [UInt8] = []
        var i = 0
        while i < input.count {
            let remaining = input.count - i
            let block = min(7, remaining)
            var msb: UInt8 = 0
            var data: [UInt8] = []
            for j in 0..<block {
                let b = input[i + j]
                if (b & 0x80) != 0 { msb |= (1 << j) }
                data.append(b & 0x7F)
            }
            out.append(msb)
            out.append(contentsOf: data)
            i += block
        }
        return out
    }

    // Unpack 7-bit-safe representation back to original bytes.
    static func decode7Bit(_ input: [UInt8]) -> [UInt8] {
        var out: [UInt8] = []
        var i = 0
        while i < input.count {
            let msb = input[i]
            i += 1
            // remaining bytes in this block are up to 7 or fewer if end.
            let rem = input.count - i
            let block = min(7, rem)
            for j in 0..<block {
                var b = input[i + j] & 0x7F
                if (msb & (1 << j)) != 0 { b |= 0x80 }
                out.append(b)
            }
            i += block
        }
        return out
    }
}

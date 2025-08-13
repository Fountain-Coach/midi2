import XCTest
import SwiftCheck
@testable import MIDI2

final class Uint4FuzzTests: XCTestCase {
    func testUint4Range() {
        property("Uint4 validates range") <- forAll { (x: UInt8) in
            if x < 0x10 {
                return (try? Uint4(validating: x)) != nil
            } else {
                return (try? Uint4(validating: x)) == nil
            }
        }
    }
}

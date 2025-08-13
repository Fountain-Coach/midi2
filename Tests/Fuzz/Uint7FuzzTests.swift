import XCTest
import SwiftCheck
@testable import MIDI2

final class Uint7FuzzTests: XCTestCase {
    func testUint7Range() {
        property("Uint7 validates range") <- forAll { (x: UInt8) in
            if x < 0x80 {
                return (try? Uint7(validating: x)) != nil
            } else {
                return (try? Uint7(validating: x)) == nil
            }
        }
    }
}

import XCTest
import SwiftCheck
@testable import MIDI2

final class Uint14FuzzTests: XCTestCase {
    func testUint14Range() {
        property("Uint14 validates range") <- forAll { (x: UInt16) in
            if x < 0x4000 {
                return (try? Uint14(validating: x)) != nil
            } else {
                return (try? Uint14(validating: x)) == nil
            }
        }
    }
}

import XCTest
@testable import CodexKitAdmission

final class RemoteInvocationGateTests: XCTestCase {
    func testMIDI2DiscoveryRemainsPublic() {
        XCTAssertEqual(CodexKitRemoteInvocationGate.decide(
            topic: "reframe/capability.discover", instrumentID: nil, operation: nil), .allowDiscovery)
    }

    func testEveryUnauthenticatedExecutableOperationIsRefused() {
        let operations = [
            "codex/account.status", "codex/thread.list", "codex/thread.create",
            "codex/thread.resume", "codex/thread.inspect", "codex/turn.submit",
            "codex/turn.cancel", "codex/approval.respond",
            "codex/session.status", "codex/session.resume"
        ]
        for operation in operations {
            XCTAssertEqual(CodexKitRemoteInvocationGate.decide(
                topic: "reframe/capability.invoke",
                instrumentID: "fountaincoach.codexkit@0.1.0",
                operation: operation), .refuseExecution, operation)
        }
    }

    func testClaimedSessionMetadataCannotAuthorizeOrBroadenInstrument() {
        XCTAssertEqual(CodexKitRemoteInvocationGate.decide(
            topic: "reframe/capability.invoke",
            instrumentID: "fountaincoach.codexkit@0.1.0", operation: "codex/turn.submit"
        ), .refuseExecution)
        XCTAssertEqual(CodexKitRemoteInvocationGate.decide(
            topic: "reframe/capability.invoke", instrumentID: "other.instrument",
            operation: "codex/turn.submit"), .ignore)
        XCTAssertEqual(CodexKitRemoteInvocationGate.decide(
            topic: "other.topic", instrumentID: "fountaincoach.codexkit@0.1.0",
            operation: "codex/turn.submit"), .ignore)
    }
}

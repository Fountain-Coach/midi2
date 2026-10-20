import Foundation

/// A narrowly scoped private Userland projection, encrypted by the already
/// provisioned Chapter 149 session. This is conversation custody, NOT a book.
public struct CodexKitUserlandRequest: Codable, Equatable, Sendable {
    public enum Operation: String, Codable, Sendable {
        case store = "userland.archive.store"
        case load = "userland.archive.load"
    }
    public let operation: Operation
    public let archiveID: String
    public let archiveData: Data?

    public init(operation: Operation, archiveID: String, archiveData: Data? = nil) throws {
        guard !archiveID.isEmpty, archiveID.utf8.count <= 64,
              archiveID.utf8.allSatisfy({ b in
                  (48...57).contains(b) || (65...90).contains(b) ||
                  (97...122).contains(b) || b == 45
              }) else { throw CodexKitProtectedSessionError.invalidBinding }
        switch operation {
        case .store:
            guard let archiveData, !archiveData.isEmpty,
                  archiveData.count <= 16_384 else {
                throw CodexKitProtectedSessionError.oversized
            }
        case .load:
            guard archiveData == nil else { throw CodexKitProtectedSessionError.wrongOperation }
        }
        self.operation = operation
        self.archiveID = archiveID
        self.archiveData = archiveData
    }

    public func validated() throws {
        _ = try Self(operation: operation, archiveID: archiveID, archiveData: archiveData)
    }
}

public struct CodexKitUserlandReply: Codable, Equatable, Sendable {
    public enum Status: String, Codable, Sendable {
        case stored, restored, absent, conflict
    }
    public let operation: CodexKitUserlandRequest.Operation
    public let archiveID: String
    public let status: Status
    public let archiveData: Data?

    public init(operation: CodexKitUserlandRequest.Operation,
                archiveID: String, status: Status, archiveData: Data? = nil) {
        self.operation = operation
        self.archiveID = archiveID
        self.status = status
        self.archiveData = archiveData
    }
}

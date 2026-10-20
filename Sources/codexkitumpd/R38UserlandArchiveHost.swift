import Foundation
#if os(Linux)
import Glibc

/// Fixed-root, device-provisioned conversation archive. Never serves arbitrary
/// files, never writes books. Each accepted revision has a durable predecessor.
struct R38UserlandArchiveHost {
    private let base = URL(fileURLWithPath: "/var/lib/fountaincoach/userland/r38/composer")
    private struct Snapshot: Codable {
        struct Exchange: Codable { let id: String; let prompt: String; let response: String; let threadID: String? }
        let schemaVersion: Int
        let exchanges: [Exchange]
        let threadID: String?
    }

    func perform(_ request: CodexKitUserlandRequest) throws -> CodexKitUserlandReply {
        try request.validated()
        guard ensureRootStorage() else { throw StorageError.untrustedStorage }
        let filename = base.appendingPathComponent(request.archiveID + ".json")
        let existing = try read(filename)
        switch request.operation {
        case .load:
            return .init(operation: .load, archiveID: request.archiveID,
                         status: existing == nil ? .absent : .restored, archiveData: existing)
        case .store:
            guard let next = request.archiveData else { throw StorageError.invalidArchive }
            let parsed = try parse(next)
            if let existing {
                let old = try parse(existing)
                if old.exchanges.count > parsed.exchanges.count ||
                   (old.exchanges.count == parsed.exchanges.count && existing != next) ||
                   !zip(old.exchanges, parsed.exchanges).allSatisfy({
                       $0.id == $1.id && $0.prompt == $1.prompt &&
                       $0.response == $1.response && $0.threadID == $1.threadID
                   }) {
                    return .init(operation: .store, archiveID: request.archiveID, status: .conflict)
                }
                if existing == next {
                    return .init(operation: .store, archiveID: request.archiveID, status: .stored)
                }
                let predecessor = base.appendingPathComponent(
                    request.archiveID + ".revision-" + String(old.exchanges.count) + ".json")
                if !FileManager.default.fileExists(atPath: predecessor.path) {
                    try atomicWrite(existing, to: predecessor)
                }
            }
            try atomicWrite(next, to: filename)
            guard try read(filename) == next else { throw StorageError.writeUnverified }
            return .init(operation: .store, archiveID: request.archiveID, status: .stored)
        }
    }

    enum StorageError: Error { case untrustedStorage, invalidArchive, writeUnverified }

    private func parse(_ data: Data) throws -> Snapshot {
        guard !data.isEmpty, data.count <= 16_384,
              let decoded = try? JSONDecoder().decode(Snapshot.self, from: data),
              decoded.schemaVersion == 1,
              decoded.exchanges.count <= 80,
              decoded.exchanges.allSatisfy({ $0.prompt.utf8.count < 6000 &&
                   $0.response.utf8.count < 6000 }) else {
            throw StorageError.invalidArchive
        }
        return decoded
    }

    private func ensureRootStorage() -> Bool {
        let manager = FileManager.default
        do {
            try manager.createDirectory(at: base, withIntermediateDirectories: true)
            let path = base.path
            guard chmod(path, mode_t(0o700)) == 0 else { return false }
            var info = stat()
            return lstat(path, &info) == 0 && info.st_uid == 0 &&
                (info.st_mode & mode_t(S_IFMT)) == mode_t(S_IFDIR)
        } catch { return false }
    }

    private func read(_ url: URL) throws -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        var info = stat()
        guard lstat(url.path, &info) == 0 && info.st_uid == 0 &&
            (info.st_mode & mode_t(S_IFMT)) == mode_t(S_IFREG) &&
            (info.st_mode & mode_t(0o077)) == 0 &&
            info.st_size > 0 && info.st_size <= 16_384 else {
            throw StorageError.untrustedStorage
        }
        return try Data(contentsOf: url)
    }

    private func atomicWrite(_ data: Data, to url: URL) throws {
        let folder = url.deletingLastPathComponent()
        let temporary = folder.appendingPathComponent(UUID().uuidString + ".pending")
        defer { try? FileManager.default.removeItem(at: temporary) }
        try data.write(to: temporary, options: .atomic)
        guard chmod(temporary.path, mode_t(0o600)) == 0 else { throw StorageError.untrustedStorage }
        if rename(temporary.path, url.path) != 0 { throw StorageError.writeUnverified }
    }
}
#endif

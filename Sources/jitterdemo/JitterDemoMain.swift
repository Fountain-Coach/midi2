import Foundation

@main
struct JitterDemo {
  /// Single, explicit async entry point (no top-level execution elsewhere).
  @MainActor
  static func main() async {
    do {
      // Construct only Sendable/actor-safe values here.
      let app = JitterApp()
      try await app.run()
    } catch {
      let message = "jitterdemo failed: \(error)\n"
      if let data = message.data(using: .utf8) {
        do {
          try FileHandle.standardError.write(contentsOf: data)
        } catch {
          // intentionally ignore stderr write failures
        }
      }
    }
  }
}

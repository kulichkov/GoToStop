import OSLog

let logger: Logger? = {
    guard let subsystem = Bundle.main.bundleIdentifier else { return nil }
    return Logger(
        subsystem: subsystem,
        category: Bundle.main.bundleURL.lastPathComponent
    )
}()

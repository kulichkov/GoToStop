//
//  LogExporter.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 05.02.25.
//

import Foundation
import OSLog

private let exporterLogger = Logger.make(category: "LogExporter")

enum LogExporterError: Error {
    case noDocumentDirectoryUrl
    case failedToCreateZip(Error)
}

extension OSLogEntryLog.Level {
    var name: String {
        switch self {
        case .undefined:
            "Undefined"
        case .debug:
            "Debug"
        case .info:
            "Info"
        case .notice:
            "Notice"
        case .error:
            "Error"
        case .fault:
            "Fault"
        @unknown default:
            "Unknown"
        }
    }
}

class LogExporter {
    func getLogs() throws -> URL {
        let documentDirectory = try getDocumentDirectory()
        let logsDirUrl = documentDirectory.appendingPathComponent(dirName)
        let jsonFileUrl = logsDirUrl.appendingPathComponent(jsonFileName)
        let zipFileUrl = documentDirectory.appendingPathComponent(zipFileName)
    
        // Remove previous items if they exist
        try removeItem(at: logsDirUrl)
        try removeItem(at: zipFileUrl)
        
        try createFolder(at: logsDirUrl)
        let logEntries = try retrieveLogEntries()
        try makeLogJsonFile(logEntries, at: jsonFileUrl)
        try compress(directoryUrl: logsDirUrl, to: zipFileUrl)
        try removeItem(at: logsDirUrl)
        
        return jsonFileUrl
    }
}

private extension LogExporter {
    struct FileLogEntry: Codable {
        static let formatter = ISO8601DateFormatter()
        
        let date: String
        let subsystem: String
        let category: String
        let message: String
        
        let level: String
        let activityIdentifier: UInt64
        let processIdentifier: Int32
        let threadIdentifier: UInt64
        
        init(from entry: OSLogEntryLog) {
            self.date = LogExporter.FileLogEntry.formatter.string(from: entry.date)
            self.subsystem = entry.subsystem
            self.category = entry.category
            self.message = entry.composedMessage
            self.level = entry.level.name
            self.activityIdentifier = entry.activityIdentifier
            self.processIdentifier = entry.processIdentifier
            self.threadIdentifier = entry.threadIdentifier
        }
    }
}

private extension LogExporter {
    var zipFileName: String {
        "\(dirName).zip"
    }
    
    var jsonFileName: String {
        "\(dirName).json"
    }
    
    var dirName: String {
        "\(Logger.subsystem ?? "Logs")"
    }
    
    func getDocumentDirectory() throws -> URL {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw LogExporterError.noDocumentDirectoryUrl
        }
        return documentDirectory
    }
    
    func retrieveLogEntries() throws -> [OSLogEntryLog] {
        exporterLogger?.info("Retrieve log entries")
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
        let logEntries = try logStore.getEntries().compactMap { $0 as? OSLogEntryLog }
        exporterLogger?.info("\(logEntries.count) log entries retrieved")
        return logEntries
    }
    
    func makeLogJsonFile(_ logEntries: [OSLogEntryLog], at logFileURL: URL) throws {
        exporterLogger?.info("Make JSON log file")
        let fileEntries = logEntries.map(FileLogEntry.init)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        exporterLogger?.info("Encode and write log entries to JSON log file")
        let jsonData = try encoder.encode(fileEntries)
        try jsonData.write(to: logFileURL)
    }
    
    func createFolder(at folderURL: URL) throws {
        let fileManager = FileManager.default
        exporterLogger?.info("Create folder \(folderURL)")
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        exporterLogger?.info("Folder created successfully: \(folderURL)")
    }
    
    func removeItem(at itemUrl: URL) throws {
        let fileManager = FileManager.default
        exporterLogger?.info("Delete item \(itemUrl)")
        if fileManager.fileExists(atPath: itemUrl.path) {
            try fileManager.removeItem(at: itemUrl)
            exporterLogger?.info("Successfully deleted item \(itemUrl)")
        } else {
            exporterLogger?.info("No item found at \(itemUrl)")
        }
    }

    func compress(directoryUrl: URL, to zipFileUrl: URL) throws {
        var fileManagerError: Error?
        var coordinatorError: NSError?
        let coordinator = NSFileCoordinator()
        
        let moveItem = { [weak self] (zipAccessURL: URL) in
            guard let self else { return }
            do {
                exporterLogger?.info("Move item \(zipAccessURL) to \(zipFileUrl)")
                try FileManager.default.moveItem(at: zipAccessURL, to: zipFileUrl)
                exporterLogger?.info("Successfully moved item \(zipAccessURL) to \(zipFileUrl)")
            } catch {
                fileManagerError = error
            }
        }
        
        exporterLogger?.info("Archive item \(directoryUrl) to \(zipFileUrl)")
        coordinator.coordinate(
            readingItemAt: directoryUrl,
            options: .forUploading,
            error: &coordinatorError,
            byAccessor: { zipAccessURL in moveItem(zipAccessURL) }
        )
        
        if let error = coordinatorError ?? fileManagerError {
            throw LogExporterError.failedToCreateZip(error)
        } else {
            exporterLogger?.info("Successfully archived item \(directoryUrl) to \(zipFileUrl)")
        }
    }
}

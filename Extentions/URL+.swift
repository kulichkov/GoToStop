//
//  URL+.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.02.25.
//

import Foundation

// MARK: - File-related helpers
extension URL {
    private var fileManager: FileManager {
        FileManager.default
    }
    
    var creationDate: Date? {
        guard let resourceValues = try? resourceValues(forKeys: [.creationDateKey]) else {
            logger?.error("Failed to get creation date for \(path)")
            return nil
        }
        return resourceValues.creationDate
    }
    
    var fileExists: Bool {
        fileManager.fileExists(atPath: path)
    }
}

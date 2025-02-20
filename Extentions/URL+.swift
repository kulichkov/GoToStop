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
    
    var fileExists: Bool {
        fileManager.fileExists(atPath: path)
    }
}

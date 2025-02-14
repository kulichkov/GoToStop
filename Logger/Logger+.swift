//
//  Logger+.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 05.02.25.
//

import Foundation
import OSLog

extension Logger {
    static func make(
        category: String = category
    ) -> Logger? {
        guard let subsystem else { return nil }
        
        return Logger(
            subsystem: subsystem,
            category: category
        )
    }
    
    static var category: String {
        Bundle.main.bundleURL.lastPathComponent
    }
    
    static var subsystem: String? {
        Bundle.main.bundleIdentifier
    }
}

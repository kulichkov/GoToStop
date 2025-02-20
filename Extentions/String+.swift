//
//  String+.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.02.25.
//

import Foundation
import CryptoKit

// MARK: - Constants
extension String {
    static let empty = ""
}


// MARK: - Helpers
extension String {
    /// Generate a compact and stable SHA-256 hash
    var sha256: String {
        SHA256.hash(data: Data(utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

//
//  URLComponents+.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 24.02.25.
//

import Foundation

extension URLComponents {
    var hashString: String? {
        guard let queryItems else {
            logger?.error("Failed to generate hash string for URLComponents: \(self)")
            return nil
        }
        
        let queryItemsString = queryItems
            .sorted(using: SortDescriptor(\.name))
            .map { $0.name + ($0.value ?? .empty) }
            .joined()
        
        return String((path + queryItemsString).sha256.prefix(16))
    }
}

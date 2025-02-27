//
//  URLRequest+.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 24.02.25.
//

import Foundation

extension URLRequest {
    var hashString: String? {
        guard
            let url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            logger?.error("Failed to generate hash string for request: \(self)")
            return nil
        }
        return urlComponents.hashString
    }
}

//
//  File.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 10.03.25.
//

import Foundation

protocol ForegroundSession: AnyObject, Sendable {
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

extension URLSession: ForegroundSession {
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

//
//  NetworkManagerTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 10.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

@Suite("NetworkManager tests")
struct NetworkManagerTests {
    
    enum TestError: Error {
        case noDataOrResponse
    }
    
    actor ForegroundSessionMock: ForegroundSession {
        private var data: Data?
        private let urlResponse: URLResponse = URLResponse(
            url: URL(string: "https://some-rmv-api.com")!,
            mimeType: nil,
            expectedContentLength: Int.random(in: 10...100),
            textEncodingName: nil
        )
        private var error: Error?
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            guard let data else {
                throw error ?? TestError.noDataOrResponse
            }
            return (data, urlResponse)
        }
        
        func setData(_ data: Data?) {
            self.data = data
        }
        func setError(_ error: Error?) {
            self.error = error
        }
    }
    
    @Test
    func getStopLocations() async throws {
        let foregroundSessionMock = ForegroundSessionMock()
        await foregroundSessionMock.setData(#"{"stopLocationOrCoordLocation":[{"StopLocation":{}},{"CoordLocation":{}}]}"#.data(using: .utf8))
        let networkManager = NetworkManager(foregroundUrlSession: foregroundSessionMock)
        
        _ = try await networkManager.getStopLocations(inputs: [UUID().uuidString])
    }
    
    @Test
    func getDepartures() async throws {
        let foregroundSessionMock = ForegroundSessionMock()
        await foregroundSessionMock.setData(#"{"Departure":[]}"#.data(using: .utf8))
        let networkManager = NetworkManager(foregroundUrlSession: foregroundSessionMock)
        
        let request = DepartureBoardRequest(
            stopId: UUID().uuidString,
            lineId: UUID().uuidString,
            directionId: UUID().uuidString,
            date: UUID().uuidString,
            time: UUID().uuidString,
            duration: Int.random(in: 60...180),
            maxJourneys: Int.random(in: 1...10)
        )
        _ = try await networkManager.getDepartures([request])
    }
}

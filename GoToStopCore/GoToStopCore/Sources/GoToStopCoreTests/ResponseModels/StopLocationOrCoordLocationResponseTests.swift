//
//  StopLocationOrCoordLocationResponseTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 10.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

@Suite("StopLocationOrCoordLocationResponse tests", .tags(.responseModels))
struct StopLocationOrCoordLocationResponseTests {
    
    @Test(arguments: [
        #"{"CoordLocation": {},}"#,
        #"{"StopLocation": {},}"#,
    ])
    func initFromDecoder(_ jsonString: String) throws {
        let rawJsonData = try #require(jsonString.data(using: .utf8))
        let decoder = JSONDecoder()
        _ = try decoder.decode(StopLocationOrCoordLocationResponse.self, from: rawJsonData)
    }
    
    @Test
    func decodingError() throws {
        let jsonString = #"{"SomeLocation": {},}"#
        let rawJsonData = try #require(jsonString.data(using: .utf8))
        let decoder = JSONDecoder()
        
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(StopLocationOrCoordLocationResponse.self, from: rawJsonData)
        }
    }
    
}


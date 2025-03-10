//
//  DepartureResponseTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 08.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

private extension DepartureResponse {
    static func mock(ref: String?) -> DepartureResponse {
        .init(
            journeyDetailRef: .init(ref: ref),
            product: [],
            name: nil,
            type: nil,
            stop: nil,
            stopid: nil,
            stopExtId: nil,
            lon: .zero,
            lat: .zero,
            prognosisType: nil,
            time: nil,
            date: nil,
            rtTime: nil,
            rtDate: nil,
            reachable: nil,
            cancelled: nil,
            direction: nil,
            messages: nil
        )
    }
}

@Suite("DepartureResponse tests", .tags(.responseModels))
struct DepartureResponseTests {
    
    @Test
    func departureResponseTitle() {
        let departureResponse = DepartureResponse.mock(ref: "#ZB#Bus M32#PC#")
        #expect(departureResponse.title == "Bus M32")
    }

    @Test
    func departureResponseDirectionId() {
        let departureResponse = DepartureResponse.mock(ref: "2|#VN#FT#1331#TO#3000529#TT#")
        #expect(departureResponse.directionId == "3000529")
    }
    
    @Test
    func departureResponseNilRef() {
        let departureResponse = DepartureResponse.mock(ref: nil)
        
        #expect(departureResponse.directionId == nil)
        #expect(departureResponse.title == nil)
    }
    
    @Test
    func departureResponseNoTitleInRef() {
        let departureResponse = DepartureResponse.mock(ref: "#ZB#")
        #expect(departureResponse.title == nil)
    }
    
    @Test
    func departureResponseNoDirectionInRef() {
        let departureResponse = DepartureResponse.mock(ref: "#TO#")
        #expect(departureResponse.direction == nil)
    }
    
}

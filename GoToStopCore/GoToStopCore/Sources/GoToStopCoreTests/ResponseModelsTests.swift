//
//  Untitled.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 08.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

private extension DepartureResponse {
    static let mock = DepartureResponse(
        journeyDetailRef: .init(ref: "2|#VN#1#ST#1734717291#PI#0#ZI#54529#TA#1#DA#251224#1S#3001204#1T#1331#LS#3000529#LT#1402#PU#80#RT#1#CA#1aE#ZE#M32#ZB#Bus M32#PC#6#FR#3001204#FT#1331#TO#3000529#TT#1402#"),
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

struct ResponseModelsTests {
    
    @Test
    func departureResponseTitle() {
        let departureResponse = DepartureResponse.mock
        
        #expect(departureResponse.title == "Bus M32")
    }

    @Test
    func departureResponseDirectionId() {
        let departureResponse = DepartureResponse.mock
        
        #expect(departureResponse.directionId == "3000529")
    }
    
}

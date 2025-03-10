//
//  DepartureBoardRequestTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 10.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

@Suite("DepartureBoardRequest tests", .tags(.requestModels))
struct DepartureBoardRequestTests {
    
    @Test
    func initialization() {
        let stopId = UUID().uuidString
        let lineId = UUID().uuidString
        let directionId = UUID().uuidString
        let date = UUID().uuidString
        let time = UUID().uuidString
        let duration = Int.random(in: 0...100)
        let maxJourneys = Int.random(in: 0...100)
        
        let departureBoardRequest = DepartureBoardRequest(
            stopId: stopId,
            lineId: lineId,
            directionId: directionId,
            date: date,
            time: time,
            duration: duration,
            maxJourneys: maxJourneys
        )

        #expect(departureBoardRequest.stopId == stopId)
        #expect(departureBoardRequest.lineId == lineId)
        #expect(departureBoardRequest.directionId == directionId)
        #expect(departureBoardRequest.date == date)
        #expect(departureBoardRequest.time == time)
        #expect(departureBoardRequest.duration == duration)
        #expect(departureBoardRequest.maxJourneys == maxJourneys)
    }
    
}

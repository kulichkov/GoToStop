//
//  TripTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 09.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore
import CoreLocation

@Suite("Trip tests", .tags(.domainModels))
struct TripTests {
    
    @Test
    func initialization() {
        let name = UUID().uuidString
        let direction = UUID().uuidString
        let category = TransportCategory.unknown
        let lineId = UUID().uuidString
        let directionId = UUID().uuidString
        
        let trip = Trip(
            name: name,
            direction: direction,
            category: category,
            lineId: lineId,
            directionId: directionId
        )
        
        #expect(trip.name == name)
        #expect(trip.direction == direction)
        #expect(trip.category == category)
        #expect(trip.lineId == lineId)
        #expect(trip.directionId == directionId)
    }
    
}

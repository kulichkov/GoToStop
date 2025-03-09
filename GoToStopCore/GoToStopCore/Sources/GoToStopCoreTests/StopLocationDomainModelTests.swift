//
//  StopLocationDomainModelTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 09.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore
import CoreLocation

struct StopLocationDomainModelTests {
    
    @Test
    func publicInitAndLocationProperty() {
        let locationId = UUID().uuidString
        let name = UUID().uuidString
        let latitude = Double.random(in: 0...1000)
        let longitude = Double.random(in: 0...1000)
        
        let stopLocation = StopLocation(
            locationId: locationId,
            name: name,
            latitude: latitude,
            longitude: longitude
        )
        
        #expect(stopLocation.locationId == locationId)
        #expect(stopLocation.name == name)
        #expect(stopLocation.latitude == latitude)
        #expect(stopLocation.longitude == longitude)
        #expect(stopLocation.location?.coordinate.latitude == latitude)
        #expect(stopLocation.location?.coordinate.longitude == longitude)
    }
    
    @Test()
    func cLLocationNil() {
        let stopLocation = StopLocation(
            locationId: UUID().uuidString,
            name: UUID().uuidString
        )
        
        #expect(stopLocation.location == nil)
    }
    
    @Test()
    func initFromResponseNil() {
        let response = StopLocationResponse(
            altId: nil,
            timezoneOffset: nil,
            id: nil,
            extId: nil,
            name: nil,
            lon: nil,
            lat: nil,
            weight: nil,
            products: nil
        )
        
        let stopLocation = StopLocation(response)
        
        #expect(stopLocation == nil)
    }
    
    @Test()
    func initFromResponse() throws {
        let extId = UUID().uuidString
        let name = UUID().uuidString
        let latitude = Double.random(in: 0...1000)
        let longitude = Double.random(in: 0...1000)
        
        let response = StopLocationResponse(
            altId: nil,
            timezoneOffset: nil,
            id: nil,
            extId: extId,
            name: name,
            lon: longitude,
            lat: latitude,
            weight: nil,
            products: nil
        )
        
        let stopLocation = try #require(StopLocation(response))
        
        #expect(stopLocation.locationId == extId)
        #expect(stopLocation.name == name)
        #expect(stopLocation.latitude == latitude)
        #expect(stopLocation.longitude == longitude)
        #expect(stopLocation.location?.coordinate.latitude == latitude)
        #expect(stopLocation.location?.coordinate.longitude == longitude)
    }
    
    @Test()
    func sortedByDistance() {
        let currentLocation = CLLocation(latitude: 50.11420, longitude: 8.62608)
        
        let kuhwaldstrasseStop = StopLocation(
            locationId: UUID().uuidString,
            name: "Kuhwaldstrasse",
            latitude: 50.11694,
            longitude: 8.64063
        )
        
        let leonardoDaVinciAlleeStop = StopLocation(
            locationId: UUID().uuidString,
            name: "Leonardo Da Vinci Allee",
            latitude: 50.11350,
            longitude: 8.62697
        )

        let hauptbahnhofStop = StopLocation(
            locationId: UUID().uuidString,
            name: "Ffm Hauptbahnhof",
            latitude: 50.10729,
            longitude: 8.66364
        )
        
        let noCoordinatesStop = StopLocation(
            locationId: UUID().uuidString,
            name: "Stop without coordinates"
        )
        
        let stops = [
            noCoordinatesStop,
            kuhwaldstrasseStop,
            hauptbahnhofStop,
            leonardoDaVinciAlleeStop
        ]
        
        let sortedStops1 = stops.sortedByDistance(from: currentLocation)
        
        #expect(sortedStops1[0].locationId == leonardoDaVinciAlleeStop.locationId)
        #expect(sortedStops1[1].locationId == kuhwaldstrasseStop.locationId)
        #expect(sortedStops1[2].locationId == hauptbahnhofStop.locationId)
        #expect(sortedStops1[3].locationId == noCoordinatesStop.locationId)
        
        let sortedStops2 = stops.sortedByDistance(from: nil)
        
        #expect(sortedStops2[0].locationId == stops[0].locationId)
        #expect(sortedStops2[1].locationId == stops[1].locationId)
        #expect(sortedStops2[2].locationId == stops[2].locationId)
        #expect(sortedStops2[3].locationId == stops[3].locationId)
    }
    
}

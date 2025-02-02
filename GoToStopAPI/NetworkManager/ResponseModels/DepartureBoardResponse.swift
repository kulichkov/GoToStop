//
//  DepartureBoardResponse.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation

struct DepartureBoardResponse: Decodable {
    let departures: [DepartureResponse]?

    enum CodingKeys: String, CodingKey {
        case departures = "Departure"
    }
}

public struct DepartureResponse: Decodable {
    let journeyDetailRef: JourneyDetailRefResponse? // "JourneyDetailRef": {"ref": "2|#VN#1#ST#1734717291#PI#0#ZI#54529#TA#1#DA#251224#1S#3001204#1T#1331#LS#3000529#LT#1402#PU#80#RT#1#CA#1aE#ZE#M32#ZB#Bus M32 #PC#6#FR#3001204#FT#1331#TO#3000529#TT#1402#"}
    let product: [ProductResponse]? // "Product": [{...}]
    let name: String? // "Tram 17"
    let type: String? // "ST"
    let stop: String? // "Frankfurt (Main) Kuhwaldstraße"
    let stopid: String? // "A=1@O=Frankfurt (Main) Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@"
    let stopExtId: String? // "3001974"
    let lon: Double // 8.640584
    let lat: Double // 50.116885
    let prognosisType: String? // "PROGNOSED"
    let time: String? // "20:04:00"
    let date: String? // "2024-12-07"
    let rtTime: String? // "20:04:00"
    let rtDate: String? // "2024-12-07"
    let reachable: Bool? // true
    let cancelled: Bool? // true
    let direction: String? // "Frankfurt (Main) Rebstockbad"
    
    enum CodingKeys: String, CodingKey {
        case journeyDetailRef = "JourneyDetailRef"
        case product = "Product"
        case name
        case type
        case stop
        case stopid
        case stopExtId
        case lon
        case lat
        case prognosisType
        case time
        case date
        case rtTime
        case rtDate
        case reachable
        case cancelled
        case direction
    }
}

struct JourneyDetailRefResponse: Decodable {
    let ref: String?
}

struct ProductResponse: Decodable {
    let name: String? // "Tram 17",
    let internalName: String? // "Tram 17 "
    let displayNumber: String? // "17"
    let num: String? // "12447"
    let line: String? // "17"
    let lineId: String? // "de:rmv:00000820:"
    let catOut: String? // "Tram"
    let catIn: String? // "BTH"
    let catCode: String? // "5"
    let cls: String? // "32"
    let catOutS: String? // "BTH"
    let catOutL: String? // "Hochflurstraßenbahn"
    let operatorCode: String? // "VGF"
    let admin: String? // "TRAFBT"
    let routeIdxFrom: Int? // 14
    let routeIdxTo: Int? // 17
    let matchId: String? // "170008"
}

extension DepartureResponse {
    private var refComponents: [String] {
        (journeyDetailRef?.ref ?? "")
            .split(separator: "#")
            .map(String.init)
    }
    
    private func getComponent(key: String) -> String? {
        let components = refComponents
        guard let toIndex = components.firstIndex(of: key)
        else { return nil }
        
        let directionIdIndex = components.index(after: toIndex)
        
        guard components.indices.contains(directionIdIndex) else { return nil }
        return components[directionIdIndex]
    }
    
    var directionId: String? {
        getComponent(key: "TO")
    }
    
    var title: String? {
        getComponent(key: "ZB")
    }
}

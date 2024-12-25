//
//  DepartureBoard.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation

struct DepartureBoard: Decodable {
    let departures: [Departure]

    enum CodingKeys: String, CodingKey {
        case departures = "Departure"
    }
}

public struct Departure: Decodable {
    public let journeyDetailRef: JourneyDetailRef? // "JourneyDetailRef": {"ref": "2|#VN#1#ST#1734717291#PI#0#ZI#54529#TA#1#DA#251224#1S#3001204#1T#1331#LS#3000529#LT#1402#PU#80#RT#1#CA#1aE#ZE#M32#ZB#Bus M32 #PC#6#FR#3001204#FT#1331#TO#3000529#TT#1402#"}
    public let product: [Product]? // "Product": [{...}]
    public let name: String? // "Tram 17"
    public let type: String? // "ST"
    public let stop: String? // "Frankfurt (Main) Kuhwaldstraße"
    public let stopid: String? // "A=1@O=Frankfurt (Main) Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@"
    public let stopExtId: String? // "3001974"
    public let lon: Double // 8.640584
    public let lat: Double // 50.116885
    public let prognosisType: String? // "PROGNOSED"
    public let time: String? // "20:04:00"
    public let date: String? // "2024-12-07"
    public let rtTime: String? // "20:04:00"
    public let rtDate: String? // "2024-12-07"
    public let reachable: Bool? // true
    public let direction: String? // "Frankfurt (Main) Rebstockbad"
    
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
        case direction
    }
}

public struct JourneyDetailRef: Decodable, Hashable {
    let ref: String?
}

public struct Product: Decodable, Hashable {
    let name: String? // "Tram 17",
    let internalName: String? // "Tram 17 "
    let displayNumber: String? // "17"
    let num: String? // "12447"
    public let line: String? // "17"
    let lineId: String? // "de:rmv:00000820:"
    public let catOut: String? // "Tram"
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

public extension Departure {
    var directionId: String? {
        guard
            let components = journeyDetailRef?.ref?.split(separator: "#"),
            let toIndex = components.firstIndex(of: "TO")
        else { return nil }
        
        let directionIdIndex = components.index(after: toIndex)
        
        guard components.indices.contains(directionIdIndex) else { return nil }
        return String(components[directionIdIndex])
    }
}

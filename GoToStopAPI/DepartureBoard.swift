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
    public let name: String? //"Tram 17",
    public let type: String? //"ST",
    public let stop: String? //"Frankfurt (Main) Kuhwaldstraße",
    public let stopid: String? //"A=1@O=Frankfurt (Main) Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@",
    public let stopExtId: String? //"3001974",
    public let lon: Double //8.640584,
    public let lat: Double //50.116885,
    public let prognosisType: String?//"PROGNOSED",
    public let time: String? //"20:04:00",
    public let date: String? //"2024-12-07",
    public let rtTime: String? //"20:04:00",
    public let rtDate: String? //"2024-12-07",
    public let reachable: Bool? //true,
    public let direction: String? //"Frankfurt (Main) Rebstockbad",
}

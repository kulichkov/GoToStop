//
//  DepartureBoard.swift
//  GoToStop
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

struct Departure: Decodable {
    let name: String? //"Tram 17",
    let type: String? //"ST",
    let stop: String? //"Frankfurt (Main) Kuhwaldstraße",
    let stopid: String? //"A=1@O=Frankfurt (Main) Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@",
    let stopExtId: String? //"3001974",
    let lon: Double //8.640584,
    let lat: Double //50.116885,
    let prognosisType: String?//"PROGNOSED",
    let time: String? //"20:04:00",
    let date: String? //"2024-12-07",
    let rtTime: String? //"20:04:00",
    let rtDate: String? //"2024-12-07",
    let reachable: Bool? //true,
    let direction: String? //"Frankfurt (Main) Rebstockbad",
}

//
//  StopLocationResponse.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

struct StopLocationResponse: Codable {
    let altId: [String]? // [ "de:06412:1974" ]
    let timezoneOffset: Int? // 60
    let id: String? // "A=1@O=F Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@B=1@p=1734544410@"
    let extId: String? // "3001974"
    let name: String? // "F Kuhwaldstraße"
    let lon: Double? // 8.640584
    let lat: Double? // 50.116885
    let weight: Double? // 2422
    let products: Int? // 111
}

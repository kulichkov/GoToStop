//
//  CoordLocationResponse.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

struct CoordLocationResponse: Decodable {
    let id: String? // "A=2@O=Kuhwaldstraße 60486 Frankfurt am Main - Bockenheim@X=8640665@Y=50116516@U=103@b=990057711@B=1@p=1716290195@"
    let name: String? // "Kuhwaldstraße"
    let description: String? // "60486 Frankfurt am Main - Bockenheim"
    let type: String? // "ADR"
    let lon: Double? // 8.640665
    let lat: Double? // 50.116516
    let refinable: Bool? // true
}

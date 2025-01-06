//
//  LocationName.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import Foundation

struct LocationName: Decodable {
    let locations: [StopLocationOrCoordLocation]

    enum CodingKeys: String, CodingKey {
        case locations = "stopLocationOrCoordLocation"
    }
}

// { "StopLocation": { .... } }
public struct StopLocation: Codable, Hashable {
    public let altId: [String]? // [ "de:06412:1974" ]
    public let timezoneOffset: Int? // 60
    public let id: String? // "A=1@O=F Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@B=1@p=1734544410@"
    public let extId: String? // "3001974"
    public let name: String? // "F Kuhwaldstraße"
    public let lon: Double? // 8.640584
    public let lat: Double? // 50.116885
    public let weight: Double? // 2422
    public let products: Int? // 111
}

// { "CoordLocation": { .... } }
public struct CoordLocation: Decodable {
    public let id: String? // "A=2@O=Kuhwaldstraße 60486 Frankfurt am Main - Bockenheim@X=8640665@Y=50116516@U=103@b=990057711@B=1@p=1716290195@"
    public let name: String? // "Kuhwaldstraße"
    public let description: String? // "60486 Frankfurt am Main - Bockenheim"
    public let type: String? // "ADR"
    public let lon: Double? // 8.640665
    public let lat: Double? // 50.116516
    public let refinable: Bool? // true
}

// { "stopLocationOrCoordLocation": [....] }
enum StopLocationOrCoordLocation: Decodable {
    case coordLocation(CoordLocation)
    case stopLocation(StopLocation)
    
    enum CodingKeys: String, CodingKey {
        case coordLocation = "CoordLocation"
        case stopLocation = "StopLocation"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let stopLocation = try? container.decodeIfPresent(StopLocation.self, forKey: .stopLocation) {
            self = .stopLocation(stopLocation)
        } else if let coordLocation = try? container.decodeIfPresent(CoordLocation.self, forKey: .coordLocation) {
            self = .coordLocation(coordLocation)
        } else {
            throw DecodingError.typeMismatch(
                StopLocationOrCoordLocation.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode as CoordLocation or StopLocation"
                )
            )
        }
    }
}

//
//  StopLocationOrCoordLocationResponse.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

enum StopLocationOrCoordLocationResponse: Decodable {
    case coordLocation(CoordLocationResponse)
    case stopLocation(StopLocationResponse)
    
    enum CodingKeys: String, CodingKey {
        case coordLocation = "CoordLocation"
        case stopLocation = "StopLocation"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let stopLocation = try? container.decodeIfPresent(StopLocationResponse.self, forKey: .stopLocation) {
            self = .stopLocation(stopLocation)
        } else if let coordLocation = try? container.decodeIfPresent(CoordLocationResponse.self, forKey: .coordLocation) {
            self = .coordLocation(coordLocation)
        } else {
            throw DecodingError.typeMismatch(
                StopLocationOrCoordLocationResponse.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode as CoordLocation or StopLocation"
                )
            )
        }
    }
}

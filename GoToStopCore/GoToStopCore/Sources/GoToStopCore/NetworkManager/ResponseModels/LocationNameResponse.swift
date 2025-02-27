//
//  LocationNameResponse.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import Foundation

struct LocationNameResponse: Decodable {
    let locations: [StopLocationOrCoordLocationResponse]

    enum CodingKeys: String, CodingKey {
        case locations = "stopLocationOrCoordLocation"
    }
}

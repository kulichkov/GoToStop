//
//  StopLocation.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

public struct StopLocation: Codable {
    public let locationId: String
    public let name: String
    public let latitude: Double?
    public let longitude: Double?
    
    public init(
        locationId: String,
        name: String,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.locationId = locationId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension StopLocation {
    init?(_ response: StopLocationResponse) {
        guard let locationId = response.extId, let name = response.name
        else { return nil }
        self.init(
            locationId: locationId,
            name: name,
            latitude: response.lat,
            longitude: response.lon
        )
    }
}

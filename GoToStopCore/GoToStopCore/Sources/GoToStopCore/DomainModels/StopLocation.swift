//
//  StopLocation.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

import CoreLocation

public struct StopLocation: Codable, Sendable {
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
    public var location: CLLocation? {
        guard let latitude, let longitude
        else { return nil }
        return CLLocation(
            latitude: latitude,
            longitude: longitude
        )
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

extension [StopLocation] {
    public func sortedByDistance(from location: CLLocation?) -> Self {
        guard let location else { return self }
        return sorted { lhs, rhs in
            switch (lhs.location, rhs.location) {
            case let (lhsLocation?, rhsLocation?):
                let lhsDistance = lhsLocation.distance(from: location)
                let rhsDistance = rhsLocation.distance(from: location)
                return lhsDistance < rhsDistance
            default:
                return true
            }
        }
    }
}

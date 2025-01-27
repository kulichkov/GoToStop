//
//  StopLocation.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

public struct StopLocation: Codable {
    public let locationId: String
    public let name: String
    
    public init(
        locationId: String,
        name: String
    ) {
        self.locationId = locationId
        self.name = name
    }
}

extension StopLocation {
    init?(_ response: StopLocationResponse) {
        guard let locationId = response.extId, let name = response.name
        else { return nil }
        self.init(
            locationId: locationId,
            name: name
        )
    }
}

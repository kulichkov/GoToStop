//
//  StopLocation.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 12.01.25.
//

import AppIntents
import GoToStopCore
import CoreLocation

struct StopLocation: AppEntity {
    let id: String
    let locationId: String
    let name: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "StopLocation"
    static var defaultQuery = StopLocationQuery()
    static let idSeparator = "#"
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static func mock() -> Self {
        .init(
            id: "1234567#Stop location name",
            locationId: "1234567",
            name: "Stop location name"
        )
    }
}

struct StopLocationQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [StopLocation] {
        let ids = try await NetworkManager.shared.getStopLocations(input: string).map(\.locationId)
        let locations = try await NetworkManager.shared.getStopLocations(inputs: ids)
        let recentLocation = CLLocationManager().location
        return locations.sortedByDistance(from: recentLocation).map(StopLocation.init)
    }
    
    func entities(for identifiers: [StopLocation.ID]) async throws -> [StopLocation] {
        identifiers.compactMap(StopLocation.init)
    }
}

extension StopLocation {
    init?(identifier: String) {
        let components = identifier.split(separator: StopLocation.idSeparator)
        guard components.count == 2 else { return nil }
        self.init(
            id: identifier,
            locationId: String(components[0]),
            name: String(components[1])
        )
    }
    
    init(_ stopLocation: GoToStopCore.StopLocation) {
        let id = [
            stopLocation.locationId,
            stopLocation.name,
        ]
            .joined(separator: StopLocation.idSeparator)
        
        self.init(
            id: id,
            locationId: stopLocation.locationId,
            name: stopLocation.name
        )
    }
}

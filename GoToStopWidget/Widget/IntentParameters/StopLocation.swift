//
//  StopLocation.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 12.01.25.
//

import AppIntents
import GoToStopAPI

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
}

struct StopLocationQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [StopLocation] {
        try await NetworkManager.shared.getStopLocations(input: string).map(StopLocation.init)
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
    
    init(_ stopLocation: GoToStopAPI.StopLocation) {
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

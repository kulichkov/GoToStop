//
//  Trip.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 13.01.25.
//

import AppIntents
import GoToStopAPI

struct Trip: AppEntity, Hashable {
    let id: String
    let name: String
    let direction: String
    let category: TransportCategory
    let lineId: String
    let directionId: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Trip"
    static var defaultQuery = TripQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)\n\(direction)")
    }
    
    static func mock() -> Self {
        .init(
            id: "Tram 66#Somewhere#Tram#66#1234567",
            name: "Tram 66",
            direction: "Somewhere",
            category: .tram,
            lineId: "66",
            directionId: "1234567"
        )
    }
}

struct TripQuery: EntityQuery {
    @IntentParameterDependency<GoToStopIntent>(\.$stopLocation)
    var goToStopIntent
    
    func suggestedEntities() async throws -> [Trip] {
        guard let stop = goToStopIntent?.stopLocation else {
            return []
        }
        
        let departures = try await NetworkManager.shared.getDepartures(stopId: stop.locationId)
        let stopDepartures = departures.filter { $0.stopId.contains(stop.locationId) }
        
        let trips: [Trip] = stopDepartures.map(Trip.init)
        let sortDescriptors: [SortDescriptor<Trip>] = [
            SortDescriptor(\.category),
            SortDescriptor(\.name, order: .forward),
            SortDescriptor(\.direction, order: .forward)
        ]
        
        return Array(Set(trips))
            .sorted(using: sortDescriptors)
    }
    
    func entities(for identifiers: [String]) async throws -> [Trip] {
        identifiers.compactMap(Trip.init)
    }
}

extension Trip {
    static let idSeparator = "#"
    
    init?(identifier: String) {
        let components = identifier.split(separator: Trip.idSeparator)
        guard components.count == 5 else { return nil }
        
        let category = TransportCategory(rawValue: String(components[2])) ?? .unknown
        
        self.init(
            id: identifier,
            name: String(components[0]),
            direction: String(components[1]),
            category: category,
            lineId: String(components[3]),
            directionId: String(components[4])
        )
    }
    
    init(_ departure: Departure) {
        let id = [
            departure.name,
            departure.direction,
            departure.category.rawValue,
            departure.lineId,
            departure.directionId,
        ]
            .joined(separator: Trip.idSeparator)
        
        self.id = id
        self.name = departure.name
        self.direction = departure.direction
        self.category = departure.category
        self.lineId = departure.lineId
        self.directionId = departure.directionId
    }
}

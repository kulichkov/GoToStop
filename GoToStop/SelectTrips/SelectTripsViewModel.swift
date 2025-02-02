//
//  SelectTripsViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 24.12.24.
//

import Foundation
import GoToStopAPI

struct TripItem: Identifiable, Hashable {
    struct Trip: Hashable {
        let category: TransportCategory
        let lineId: String
        let name: String
        let direction: String
        let directionId: String
        
        init(
            category: TransportCategory,
            lineId: String,
            name: String,
            direction: String,
            directionId: String
        ) {
            self.category = category
            self.lineId = lineId
            self.name = name
            self.direction = direction
            self.directionId = directionId
        }
        
        init(_ departure: Departure) {
            self.category = departure.category
            self.lineId = departure.lineId
            self.name = departure.name
            self.direction = departure.direction
            self.directionId = departure.directionId
        }
    }
    
    let id = UUID()
    let trip: Trip
}

final class SelectTripsViewModel: ObservableObject {
    @Published private(set) var tripItems: [TripItem] = []
    @Published var selectedItems: [TripItem] = []
    @Published var selectionProcessed = false
    
    init() {
        getTrips()
    }
    
    func handleTripTap(_ tripItem: TripItem) {
        if selectedItems.contains(tripItem) {
            guard let index = selectedItems.firstIndex(of: tripItem) else { return }
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(tripItem)
        }
    }
    
    func processSelectedTrips() {
        Settings.shared.trips = selectedItems.map { Trip(
            name: $0.trip.name,
            direction: $0.trip.direction,
            category: $0.trip.category,
            lineId: $0.trip.lineId,
            directionId: $0.trip.directionId
        ) }
    }
    
    private func getTrips() {
        Task { @MainActor in
            do {
                guard let stop = Settings.shared.stopLocation
                else { return }
                
                let request = DepartureBoardRequest(stopId: stop.locationId)
                
                let departures = try await NetworkManager.shared.getDepartures(request)
                let stopDepartures = departures.filter { $0.stopId.contains(stop.locationId) }
                
                let values: [TripItem.Trip] = stopDepartures.map(TripItem.Trip.init)
                
                let sortDescriptors: [SortDescriptor<TripItem>] = [
                    SortDescriptor(\.trip.category),
                    SortDescriptor(\.trip.name, order: .forward),
                    SortDescriptor(\.trip.direction, order: .forward)
                ]
                
                tripItems = Array(Set(values))
                    .map(TripItem.init)
                    .sorted(using: sortDescriptors)
                
                debugPrint(tripItems)
            } catch {
                debugPrint(error)
            }
        }
    }
    
}


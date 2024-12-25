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
        let category: String
        let line: String
        let name: String
        let direction: String
        let directionId: String
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
            line: $0.trip.line,
            directionId: $0.trip.directionId
        ) }
    }
    
    private func getTrips() {
        Task { @MainActor in
            do {
                guard
                    let stop = Settings.shared.stopLocation,
                    let stopId = stop.id,
                    let locationId = stop.locationId
                else {
                    return
                }
                
                let departures = try await NetworkManager.shared.getDepartures(stopId: stopId)
                let stopDepartures = departures.filter { $0.stopid?.contains(locationId) ?? false }
                
                let values: [TripItem.Trip] = stopDepartures.compactMap {
                    guard
                        let product = $0.product?.first,
                        let line = product.line,
                        let name = $0.name,
                        let category = product.catOut,
                        let direction = $0.direction,
                        let directionId = $0.directionId
                    else { return nil }
                    return TripItem.Trip(
                        category: category,
                        line: line,
                        name: name,
                        direction: direction,
                        directionId: directionId
                    )
                }
                
                let sortDescriptors: [SortDescriptor<TripItem>] = [
                    SortDescriptor(\.trip.category),
                    SortDescriptor(\.trip.line, order: .forward),
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

private extension StopLocation {
    var locationId: String? {
        id?
            .split(separator: "@")
            .first { $0.hasPrefix("L=") }
            .map(String.init)
    }
}


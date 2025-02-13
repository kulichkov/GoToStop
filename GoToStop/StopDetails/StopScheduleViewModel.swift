//
//  StopScheduleViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 26.01.25.
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

final class StopScheduleViewModel: ObservableObject {
    @Published var stop: StopLocation
    @Published var trips: [TripItem]
    @Published var scheduleItems: [ScheduleItem]
    
    convenience init(_ parameters: StopScheduleParameters) {
        self.init(
            stop: parameters.stopLocation,
            trips: parameters.tripItems
        )
    }
    
    init(
        stop: StopLocation,
        trips: [TripItem],
        scheduleItems: [ScheduleItem] = []
    ) {
        self.stop = stop
        self.trips = trips
        self.scheduleItems = scheduleItems
        
        fetchSchedule(
            stopId: stop.locationId,
            tripItems: trips
        )
    }
    
    func handleWidgetURL(_ url: URL?) {
        debugPrint(#function)
        guard let parameters = url?.getStopScheduleParameters() else {
            debugPrint(#function, "Couldn't get parameters from URL \(String(describing: url))")
            return
        }
        stop = parameters.stopLocation
        trips = parameters.tripItems
        
        fetchSchedule(
            stopId: stop.locationId,
            tripItems: trips
        )
    }
    
    private func fetchSchedule(
        stopId: String,
        tripItems: [TripItem]
    ) {
        let duration: Int = 60 * max(1, min(8/tripItems.count, 8))
        debugPrint(#function, "duration set to: \(duration)")
        
        let departureRequests = tripItems.map { tripItem in
            DepartureBoardRequest(
                stopId: stopId,
                lineId: tripItem.trip.lineId,
                directionId: tripItem.trip.directionId,
                duration: duration
            )
        }
        
        Task { @MainActor in
            let fetchedDepartures: [Departure]
            do {
                fetchedDepartures = try await NetworkManager.shared.getDepartures(departureRequests)
            } catch {
                fetchedDepartures = []
                debugPrint(error)
            }
            scheduleItems = fetchedDepartures
                .compactMap(ScheduleItem.init)
                .sorted(using: SortDescriptor(\.time))
        }
    }
}

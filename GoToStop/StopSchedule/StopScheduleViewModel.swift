//
//  StopScheduleViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 26.01.25.
//

import Foundation
import GoToStopAPI

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
                .sorted(using: SortDescriptor(\.scheduledTime))
                .compactMap(ScheduleItem.init)
        }
    }
}

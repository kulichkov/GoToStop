//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI

final class GoToStopWidgetViewModel: ObservableObject {
    private var hasInitialEntry = false
    
    @MainActor
    func getWidgetEntries() async throws -> [GoToStopWidgetEntry] {
        let scheduledItems = await getTrips()
        return makeWidgetEntries(scheduledItems)
    }
    
    private func makeWidgetEntries(_ scheduledTrips: [ScheduledTrip]) -> [GoToStopWidgetEntry] {
        let dates = makeUpdateDates(
            startDate: scheduledTrips.first?.time,
            endDate: scheduledTrips.last?.time
        )
        
        var entries: [GoToStopWidgetEntry] = []
        
        let stopName = Settings.shared.stopLocation?.name ?? ""
        
        for timeToUpdate in dates {
            let items = scheduledTrips
                .map { $0.makeScheduledItem(relatedDate: timeToUpdate) }
                .filter { trip in
                guard let time = trip.time else { return false }
                return time >= timeToUpdate
            }
            
            let entry = GoToStopWidgetEntry(
                date: timeToUpdate,
                data: .init(
                    stop: stopName,
                    items: items
                )
            )
            
            entries.append(entry)
        }
        
        return entries
    }
    
    private func makeUpdateDates(
        startDate: Date?,
        endDate: Date?,
        interval: TimeInterval = 60
    ) -> [Date] {
        guard let startDate, let endDate else { return [] }
        
        var updateDates = stride(
            from: .zero,
            to: endDate.timeIntervalSince(startDate),
            by: interval
        )
        .map(startDate.addingTimeInterval)
        
        // Insert the current time to update widget immediately
        updateDates.insert(.now, at: .zero)
        
        return updateDates
    }
    
    private func getTrips() async -> [ScheduledTrip] {
        guard let stopId = Settings.shared.stopLocation?.locationId
        else { return [] }
        
        let trips = Settings.shared.trips
        
        let fetchedDepartures: [Departure]
        do {
            fetchedDepartures = try await NetworkManager.shared.getDepartures(
                stopId: stopId,
                departureLines: trips.map {
                    DepartureLineRequest(id: $0.lineId, directionId: $0.directionId)
                }
            )
        } catch {
            fetchedDepartures = []
            debugPrint(error)
        }
        
        return fetchedDepartures
            .compactMap(ScheduledTrip.init)
            .sorted(using: SortDescriptor(\.time))
    }
}

private extension ScheduledTrip {
    init?(_ departure: Departure) {
        self.init(
            name: departure.name,
            direction: departure.direction,
            scheduledTime: departure.scheduledTime,
            realTime: departure.realTime
        )
    }
    
    func makeScheduledItem(relatedDate: Date) -> ScheduleItem {
        let minutesLeft = time
            .map { max(.zero, $0.timeIntervalSince(relatedDate) / 60) }
            .map(UInt.init)
        
        return ScheduleItem(
            name: name,
            direction: direction,
            time: time,
            minutesLeft: minutesLeft
        )
    }
}

//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI

final class GoToStopWidgetViewModel: ObservableObject {
    
    func getWidgetEntries() async throws -> [GoToStopWidgetEntry] {
        let scheduledItems = await getTrips()
        return makeWidgetEntries(scheduledItems)
    }
    
    private func makeWidgetEntries(_ scheduledTrips: [ScheduledTrip]) -> [GoToStopWidgetEntry] {
        let dates = makeUpdateDates()
        
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
        endDate: Date? = nil,
        interval: TimeInterval = 60
    ) -> [Date] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: .now)
        components.second = .zero
        components.minute? += 1
        
        guard let startDate = calendar.date(from: components) else { return [] }
        
        // If no endDate then default 10 minutes
        let endDate = endDate ?? startDate.addingTimeInterval(60 * 10)
        
        var updateDates = stride(
            from: .zero,
            to: endDate.timeIntervalSince(startDate),
            by: interval
        )
        .map(startDate.addingTimeInterval)
        
        if updateDates.first != .now {
            updateDates.insert(.now, at: .zero)
        }

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
            .map { max(.zero, ceil($0.timeIntervalSince(relatedDate) / 60)) }
            .map(UInt.init)
        
        return ScheduleItem(
            name: name,
            direction: direction,
            time: time,
            minutesLeft: minutesLeft
        )
    }
}

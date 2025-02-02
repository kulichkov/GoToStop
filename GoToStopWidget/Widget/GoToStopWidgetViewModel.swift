//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI
import CoreLocation

extension GoToStopWidgetViewModel {
    struct Constant {
        let secondsInMinute: TimeInterval = 60
        let uiUpdateTimeInterval: TimeInterval = 60
        let tenMinutes: TimeInterval = 60 * 10
    }
}

enum GoToStopWidgetError: Error {
    case noParametersSet
}

final class GoToStopWidgetViewModel: ObservableObject {
    private let constant = Constant()
    
    init() {
        CLLocationManager().requestWhenInUseAuthorization()
    }
    
    func getWidgetEntries(
        _ intent: GoToStopIntent
    ) async throws -> [GoToStopWidgetEntry] {
        guard
            let stopId = intent.stopLocation?.locationId,
            let trips = intent.trips
        else {
            throw GoToStopWidgetError.noParametersSet
        }
        let scheduledItems = try await getTrips(stopId: stopId, trips: trips)
        
        let stopName = intent.stopLocation?.name ?? "No stop name"
        return makeWidgetEntries(
            stopName: stopName,
            items: scheduledItems,
            stop: intent.stopLocation,
            trips: intent.trips ?? []
        )
    }
    
    private func makeWidgetEntries(
        stopName: String?,
        items scheduledTrips: [ScheduledTrip],
        stop: StopLocation?,
        trips: [Trip]
    ) -> [GoToStopWidgetEntry] {
        // Make the end date be a minute later then the last scheduled trip
        // to show an empty widget instead of outdated trips
        let endDate = scheduledTrips.last?.scheduledTime?.addingTimeInterval(2 * constant.secondsInMinute)
        
        let dates = makeUpdateDates(
            endDate: endDate,
            interval: constant.uiUpdateTimeInterval
        )
        
        var entries: [GoToStopWidgetEntry] = []
        
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
                    updateTime: .now,
                    stop: stopName,
                    items: items
                ),
                stop: stop,
                trips: trips
            )
            
            entries.append(entry)
        }
        
        return entries
    }
    
    private func makeUpdateDates(
        endDate: Date?,
        interval: TimeInterval
    ) -> [Date] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: .now)
        components.second = .zero
        components.minute? += 1
        
        guard let startDate = calendar.date(from: components) else { return [] }
        
        // If no endDate then default 10 minutes
        let endDate = endDate ?? startDate.addingTimeInterval(constant.tenMinutes)
        
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
    
    private func getTrips(stopId: String, trips: [Trip]) async throws -> [ScheduledTrip] {
        let duration: Int = 60 * max(1, min(8/trips.count, 8))
        debugPrint(#function, "duration set to: \(duration) for \(trips.count) trip(s)")
        let departureRequests = trips.map {
            DepartureBoardRequest(
                stopId: stopId,
                lineId: $0.lineId,
                directionId: $0.directionId,
                duration: duration
            )
        }
        let fetchedDepartures = try await NetworkManager.shared.getDepartures(departureRequests)
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
            isCancelled: departure.isCancelled,
            isReachable: departure.isReachable,
            scheduledTime: departure.scheduledTime,
            realTime: departure.realTime
        )
    }
    
    func makeScheduledItem(relatedDate: Date) -> ScheduleItem {
        let secondsInMinute: TimeInterval = 60
        let minutesLeft = time
            .map { max(.zero, ceil($0.timeIntervalSince(relatedDate) / secondsInMinute)) }
            .map(UInt.init)
        
        return ScheduleItem(
            name: name,
            direction: direction,
            scheduledTime: scheduledTime,
            realTime: realTime,
            minutesLeft: minutesLeft,
            isReachable: isReachable,
            isCancelled: isCancelled
        )
    }
}

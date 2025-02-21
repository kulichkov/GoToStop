//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI
import CoreLocation
import Combine
import WidgetKit

extension GoToStopWidgetViewModel {
    struct Constant {
        let secondsInMinute: TimeInterval = 60
        let uiUpdateTimeInterval: TimeInterval = 60
        let tenMinutes: TimeInterval = 60 * 10
    }
}

enum GoToStopWidgetError: Error {
    case noStopSet
    case noTripsSet
}

final class GoToStopWidgetViewModel: ObservableObject {
    private let constant = Constant()
    private var bindings = Set<AnyCancellable>()
    
    init() {
        CLLocationManager().requestWhenInUseAuthorization()
        NetworkManager.shared.someTaskFinished
            .sink { _ in WidgetCenter.shared.reloadAllTimelines() }
            .store(in: &bindings)
    }
    
    func getWidgetEntries(
        _ intent: GoToStopIntent
    ) async throws -> [GoToStopWidgetEntry] {
        Task { getLogsIfNeeded() }
        
        logger?.info("Start getting widget entries")
        guard let stopLocation = intent.stopLocation else {
            logger?.error("No stop set in the widget")
            throw GoToStopWidgetError.noStopSet
        }
        
        guard let trips = intent.trips else {
            logger?.error("No trips set in the widget")
            throw GoToStopWidgetError.noTripsSet
        }
        
        logger?.info("Get scheduled items")
        let scheduledItems = try getTrips(
            stopId: stopLocation.locationId,
            trips: trips
        )
        logger?.info("Successfully got scheduled items: \(scheduledItems)")
        logger?.info("Stop name: \(stopLocation.name)")
        
        return makeWidgetEntries(
            stopName: stopLocation.name,
            items: scheduledItems,
            stop: stopLocation,
            trips: trips
        )
    }
    
    private func makeWidgetEntries(
        stopName: String?,
        items scheduledTrips: [ScheduledTrip],
        stop: StopLocation?,
        trips: [Trip]
    ) -> [GoToStopWidgetEntry] {
        logger?.info("Start making widget entries for stopId: \(String(describing: String(describing: stop?.locationId))), scheduledTrips: \(scheduledTrips), trips: \(trips)")
        
        // Make the end date be an hour later
        let endDate = Date.now.addingTimeInterval(60 * 60)
        logger?.info("End date: \(String(describing: endDate))")
        
        let dates = makeUpdateDates()
        logger?.info("Dates made: \(dates)")
        
        var entries: [GoToStopWidgetEntry] = []
        
        for timeToUpdate in dates {
            let items = scheduledTrips
                .map { $0.makeScheduledItem(relatedTime: timeToUpdate) }
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
        
        logger?.info("Entries made: \(entries)")
        
        return entries
    }
    
    private func makeUpdateDates() -> [Date] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: .now)
        components.second = .zero
        components.minute? += 1
        
        guard let startDate = calendar.date(from: components) else { return [] }
        
        // End date is an hour later to make widget items keep appearing
        // in case there's no timeline update
        components.hour? += 1
        guard let endDate = calendar.date(from: components) else { return [] }
        
        var updateDates = stride(
            from: .zero,
            to: endDate.timeIntervalSince(startDate),
            by: constant.uiUpdateTimeInterval
        )
        .map(startDate.addingTimeInterval)
        
        if updateDates.first != .now {
            updateDates.insert(.now, at: .zero)
        }

        return updateDates
    }
    
    private func getTrips(stopId: String, trips: [Trip]) throws -> [ScheduledTrip] {
        let departureRequests = trips.map {
            DepartureBoardRequest(
                stopId: stopId,
                lineId: $0.lineId,
                directionId: $0.directionId,
                duration: 60 * 16
            )
        }
        
        let fetchedDepartures = try departureRequests
            .compactMap { try NetworkManager.shared.requestDepartures($0) }
    
        guard departureRequests.count == fetchedDepartures.count else {
            return []
        }
        
        let trips = fetchedDepartures
            .flatMap { $0 }
            .sorted(using: SortDescriptor(\.scheduledTime))
            .prefix(100)
            .compactMap(ScheduledTrip.init)
        
        // Removing saved departures
        for request in departureRequests {
            do {
                try NetworkManager.shared.removeCachedDepartures(for: request)
            } catch {
                logger?.error("Failed to remove cached departures for \(request.stopId), \(String(describing: request.lineId)), \(String(describing: request.directionId)) : \(error)")
            }
        }
        
        return trips
    }
    
    private func getLogsIfNeeded() {
        guard Settings.shared.shouldCollectWidgetLogs else { return }
        
        logger?.info("Start collecting widget logs")
        
        do {
            let logsUrl = try LogExporter().makeJson(name: "GoToStopWidgetLogs")
            Settings.shared.shouldCollectWidgetLogs = false
            Settings.shared.widgetLogsUrl = logsUrl
            logger?.info("Widget logs in JSON collected: \(logsUrl)")
        } catch {
            logger?.error("Failed to create JSON with logs: \(error)")
        }
    }
}

private extension ScheduledTrip {
    init?(_ departure: Departure) {
        self.init(
            name: departure.name,
            direction: departure.direction,
            isCancelled: departure.isCancelled,
            isReachable: departure.isReachable,
            hasWarnings: !departure.messages.filter(\.isActive).isEmpty,
            scheduledTime: departure.scheduledTime,
            realTime: departure.realTime
        )
    }
    
    func makeScheduledItem(relatedTime: Date) -> ScheduleItem {
        ScheduleItem(
            name: name,
            direction: direction,
            scheduledTime: scheduledTime,
            realTime: realTime,
            relatedTime: relatedTime,
            isReachable: isReachable,
            isCancelled: isCancelled,
            hasWarnings: hasWarnings
        )
    }
}

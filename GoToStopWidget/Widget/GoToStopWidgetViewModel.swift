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
        NetworkManager.shared.cachedFileReady
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
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
        
        let allCacheIsReady = try checkIfAllDeparturesCached(stopId: stopLocation.locationId, trips: trips)
        if allCacheIsReady {
            logger?.info("All requested items available. Returning...")
            let departures = try getCachedDepartures(stopId: stopLocation.locationId, trips: trips)
            let scheduledTrips = mapDeparturesToScheduledTrips(departures)
            return makeWidgetEntries(
                stopName: stopLocation.name,
                items: scheduledTrips,
                stop: stopLocation,
                trips: trips
            )
        } else {
            let requestInProgress = try checkIfRequesting(stopId: stopLocation.locationId, trips: trips)
            if !requestInProgress {
                logger?.info("Requesting trips...")
                try requestDepartures(stopId: stopLocation.locationId, trips: trips)
            }
            logger?.info("Not all requested items available yet. Waiting...")
            return makeEmptyEntries(stopLocation: stopLocation, trips: trips)
        }
    }
    
    private func makeEmptyEntries(
        stopLocation: StopLocation,
        trips: [Trip]
    ) -> [GoToStopWidgetEntry] {
        [.init(
            date: .now,
            data: .init(
                updateTime: .now,
                stop: stopLocation.name,
                items: []
            ),
            widgetUrl: makeWidgetUrl(stop: stopLocation, trips: trips)
        )]
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
                widgetUrl: makeWidgetUrl(stop: stop, trips: trips)
            )
            
            entries.append(entry)
        }
        
        logger?.info("Entries made: \(entries)")
        
        return entries
    }
    
    private func makeWidgetUrl(stop: StopLocation?, trips: [Trip]) -> URL? {
        guard let stop, !trips.isEmpty else {
            return nil
        }
        
        var components = URLComponents()
        components.scheme = "gotostop"
        components.host = "widget"
        
        let stopQueryItem = URLQueryItem(name: "stop", value: stop.id)
        
        let tripsQueryItems = trips.map {
            URLQueryItem(name: "trip", value: $0.id)
        }
        let optionalItems = [stopQueryItem] + tripsQueryItems
        
        components.queryItems = optionalItems.compactMap { $0 }

        return components.url
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
    
    private func getDepartureRequests(
        stopId: String,
        trips: [Trip]
    ) -> [DepartureBoardRequest] {
        trips.map {
            DepartureBoardRequest(
                stopId: stopId,
                lineId: $0.lineId,
                directionId: $0.directionId,
                duration: 60 * 16
            )
        }
    }
    
    private func requestDepartures(
        stopId: String,
        trips: [Trip]
    ) throws {
        let requests = getDepartureRequests(stopId: stopId, trips: trips)
        for request in requests {
            try NetworkManager.shared.requestDepartures(request)
        }
    }
    
    private func checkIfAllDeparturesCached(
        stopId: String,
        trips: [Trip]
    ) throws -> Bool {
        let departureRequests = getDepartureRequests(stopId: stopId, trips: trips)
        return try departureRequests.allSatisfy {
            try NetworkManager.shared.getCachedDepartures(for: $0) != nil
        }
    }
    
    private func checkIfRequesting(
        stopId: String,
        trips: [Trip]
    ) throws -> Bool {
        let departureRequests = getDepartureRequests(stopId: stopId, trips: trips)
        let activeRequest = try departureRequests.first(where: {
            try NetworkManager.shared.checkIfActive($0)
        })
        return activeRequest != nil
    }
    
    private func getCachedDepartures(
        stopId: String,
        trips: [Trip]
    ) throws -> [[Departure]] {
        let departureRequests = getDepartureRequests(stopId: stopId, trips: trips)
        let cachedDepartures = try departureRequests.compactMap {
            try NetworkManager.shared.getCachedDepartures(for: $0)
        }
        return cachedDepartures
    }
    
    private func removeCachedDepartures(
        stopId: String,
        trips: [Trip]
    ) throws {
        let departureRequests = getDepartureRequests(stopId: stopId, trips: trips)
        for request in departureRequests {
            try NetworkManager.shared.removeCachedDepartures(for: request)
        }
    }
    
    private func mapDeparturesToScheduledTrips(
        _ departures: [[Departure]]
    ) -> [ScheduledTrip] {
        departures
            .flatMap { $0 }
            .sorted(using: SortDescriptor(\.scheduledTime))
            .prefix(100)
            .compactMap(ScheduledTrip.init)
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

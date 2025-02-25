//
//  GoToStopWidgetProviderHelper.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI
import CoreLocation
import Combine
import WidgetKit

extension GoToStopWidgetProviderHelper {
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

struct GoToStopWidgetProviderHelper {
    private let constant = Constant()
    private let stopLocation: StopLocation
    private let trips: [Trip]
    private var bindings = Set<AnyCancellable>()
    private var widgetHash: String {
        let tripsString = trips
            .sorted(using: SortDescriptor(\.lineId))
            .map { $0.lineId + $0.directionId }
            .joined()
        
        return (stopLocation.locationId + tripsString).sha256
    }
    private var widgetUrl: URL? {
        var components = URLComponents()
        components.scheme = "gotostop"
        components.host = "widget"
        
        let stopQueryItem = URLQueryItem(name: "stop", value: stopLocation.id)
        
        let tripsQueryItems = trips.map {
            URLQueryItem(name: "trip", value: $0.id)
        }
        let optionalItems = [stopQueryItem] + tripsQueryItems
        
        components.queryItems = optionalItems.compactMap { $0 }

        return components.url
    }
    
    init(
        stopLocation: StopLocation,
        trips: [Trip]
    ) {
        self.stopLocation = stopLocation
        self.trips = trips
        CLLocationManager().requestWhenInUseAuthorization()
    }
    
    func getWidgetEntries() throws -> [GoToStopWidgetEntry] {
        Task { getLogsIfNeeded() }
        
        if Settings.shared.widgetsReadyToReload.contains(widgetHash) {
            // Data is ready. Create items and return them
            logger?.debug("Data is ready. Create items and return them")
            let departures = getCachedDepartures()
            let scheduledTrips = mapDeparturesToScheduledTrips(departures)
            let widgetEntries = makeWidgetEntries(items: scheduledTrips)
            
            do {
                try removeCachedDepartures()
            } catch {
                logger?.warning("Failed to remove cached departures: \(error)")
            }
            Settings.shared.widgetsReadyToReload.remove(widgetHash)
            return widgetEntries
            
        } else if Settings.shared.activeWidgetRequests.contains(widgetHash) {
            // Data already requested. Check data availability. If the data is not available - wait.
            logger?.debug("Data already requested. Check data availability. If the data is not available - wait.")
            Task {
                logger?.debug("Starting...")
                let requestsAreInProgress = await checkIfRequestsAreInProgress()
                logger?.debug("Ended... requestsAreInProgress: \(requestsAreInProgress)")
                if !requestsAreInProgress {
                    // Requests are done. All cache files should be ready.
                    Settings.shared.activeWidgetRequests.remove(widgetHash)
                    Settings.shared.widgetsReadyToReload.insert(widgetHash)
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            
            // return empty
            return makeEmptyEntries()
        } else {
            // Data is not requested. Request.
            logger?.debug("Data is not requested. Request.")
            Settings.shared.activeWidgetRequests.insert(widgetHash)
            requestDepartures()
            
            // return empty
            return makeEmptyEntries()
        }
    }
    
    private func makeEmptyEntries() -> [GoToStopWidgetEntry] {
        [.init(
            date: .now,
            data: .init(
                updateTime: .now,
                stop: stopLocation.name,
                items: []
            ),
            widgetUrl: widgetUrl
        )]
    }
    
    private func makeWidgetEntries(
        items scheduledTrips: [ScheduledTrip]
    ) -> [GoToStopWidgetEntry] {
        logger?.info("Start making widget entries for stopId: \(stopLocation.locationId), scheduledTrips: \(scheduledTrips), trips: \(trips)")
        
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
                    stop: stopLocation.name,
                    items: items
                ),
                widgetUrl: widgetUrl
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
    
    private func getDepartureRequests() -> [DepartureBoardRequest] {
        trips.map {
            DepartureBoardRequest(
                stopId: stopLocation.locationId,
                lineId: $0.lineId,
                directionId: $0.directionId,
                duration: 60 * 16
            )
        }
    }
    
    private func requestDepartures() {
        let requests = getDepartureRequests()
        do {
            for request in requests {
                try NetworkManager.shared.requestDepartures(request)
            }
        } catch {
            logger?.error("Failed to request departures: \(error)")
        }
    }
    
    private func checkIfRequestsAreInProgress() async -> Bool {
        let requests = getDepartureRequests()
        return await NetworkManager.shared.checkIfDeparturesAreInProgress(requests)
    }
    
    private func getCachedDepartures() -> [Departure] {
        var resultCachedDepartures: [Departure] = []
        
        for request in getDepartureRequests() {
            do {
                guard let cachedDepartures = try NetworkManager.shared.getCachedDepartures(for: request) else {
                    logger?.warning("No cached departures found for \(String(describing: request))")
                    continue
                }
                resultCachedDepartures.append(contentsOf: cachedDepartures)
            } catch {
                logger?.error("Failed to get cached departures for \(String(describing: request)): \(error)")
            }
        }
        
        return resultCachedDepartures
    }
    
    private func removeCachedDepartures() throws {
        let departureRequests = getDepartureRequests()
        for request in departureRequests {
            try NetworkManager.shared.removeCachedDepartures(for: request)
        }
    }
    
    private func mapDeparturesToScheduledTrips(
        _ departures: [Departure]
    ) -> [ScheduledTrip] {
        departures
            .sorted(using: SortDescriptor(\.time))
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

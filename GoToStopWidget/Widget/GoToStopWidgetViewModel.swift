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
    case noStopSet
    case noTripsSet
}

final class GoToStopWidgetViewModel: ObservableObject {
    private let constant = Constant()
    
    init() {
        CLLocationManager().requestWhenInUseAuthorization()
    }
    
    func getWidgetEntries(
        _ intent: GoToStopIntent
    ) async throws -> [GoToStopWidgetEntry] {
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
        let scheduledItems = try await getTrips(
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
        
        // Make the end date be a minute later then the last scheduled trip
        // to show an empty widget instead of outdated trips
        let endDate = scheduledTrips.last?.scheduledTime?.addingTimeInterval(2 * constant.secondsInMinute)
        logger?.info("End date: \(String(describing: endDate))")
        
        let dates = makeUpdateDates(
            endDate: endDate,
            interval: constant.uiUpdateTimeInterval
        )
        logger?.info("Dates made: \(dates)")
        
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
        
        logger?.info("Entries made: \(entries)")
        
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
        let departureRequests = trips.map {
            DepartureBoardRequest(
                stopId: stopId,
                lineId: $0.lineId,
                directionId: $0.directionId
            )
        }
        let fetchedDepartures = try await NetworkManager.shared.getDepartures(departureRequests)
        return fetchedDepartures
            .compactMap(ScheduledTrip.init)
            .sorted(using: SortDescriptor(\.time))
    }
    
    private func getLogsIfNeeded() {
        let name1 = "\(ProcessInfo().processName)_pid\(ProcessInfo().processIdentifier)"
        logger?.debug("Logs sharing started for \(name1)")
        
        guard Settings.shared.isSharingLogs else {
            logger?.debug("No need for log sharing!")
            return
        }
        let name = "\(ProcessInfo().processName)_pid\(ProcessInfo().processIdentifier)"
        logger?.info("Logs sharing started for \(name)")
        do {
            let logUrl = try LogExporter().makeJson(name: name)
            Settings.shared.logsUrls.append(logUrl)
        } catch {
            logger?.error("Failed to export logs: \(error)")
            Settings.shared.logsErrors.append(error.localizedDescription)
        }
        logger?.info("Settings.shared.logsUrls: \(Settings.shared.logsUrls)")
        logger?.info("Settings.shared.logsErrors: \(Settings.shared.logsErrors)")
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

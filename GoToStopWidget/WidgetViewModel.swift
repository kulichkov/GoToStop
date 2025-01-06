//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI

struct WidgetData {
    let stop: String
    let items: [ScheduleItem]
}

struct ScheduleItem: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let departureTime: Date
    let minutesTillDeparture: Int
}

final class WidgetViewModel: ObservableObject {
    private lazy var serverDateTimeFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    @MainActor
    func getWidgetData() async throws -> WidgetData {
        let stopName = Settings.shared.stopLocation?.name ?? ""
        let scheduledItems = await getSchedule()
        return .init(stop: stopName, items: scheduledItems)
    }
    
    private func getSchedule() async -> [ScheduleItem] {
        guard let stopId = Settings.shared.stopLocation?.id
        else { return [] }
        
        let trips = Settings.shared.trips
        
        let fetchedDepartures: [Departure]
        do {
            fetchedDepartures = try await NetworkManager.shared.getDepartures(
                stopId: stopId,
                departureLines: trips.map { DepartureLine(id: $0.line, directionId: $0.directionId) }
            )
        } catch {
            fetchedDepartures = []
            debugPrint(error)
        }
        
        return fetchedDepartures
            .filter { $0.reachable == true }
            .sorted(using: SortDescriptor(\.rtTime))
            .compactMap { [weak self] in
                ScheduleItem(
                    $0,
                    serverDateTimeFormatter: self?.serverDateTimeFormatter
                )
            }
    }
}

private extension ScheduleItem {
    init?(_ departure: Departure, serverDateTimeFormatter: DateFormatter?) {
        guard
            let name = departure.name,
            let direction = departure.direction,
            let date = departure.rtDate ?? departure.date,
            let time = departure.rtTime ?? departure.time,
            let time = serverDateTimeFormatter?.date(from: "\(date) \(time)")
        else { return nil }
        let minutesLeft = Int((time.timeIntervalSinceNow/60).rounded(.up))
        self.init(
            name: name,
            direction: direction,
            departureTime: time,
            minutesTillDeparture: minutesLeft
        )
    }
}

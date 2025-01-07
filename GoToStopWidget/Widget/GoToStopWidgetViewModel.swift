//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI

final class GoToStopWidgetViewModel: ObservableObject {
    @MainActor
    func getWidgetData() async throws -> GoToStopWidgetData {
        let stopName = Settings.shared.stopLocation?.name ?? ""
        let scheduledItems = await getSchedule()
        return .init(stop: stopName, items: scheduledItems)
    }
    
    private func getSchedule() async -> [ScheduleItem] {
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
            .sorted(using: SortDescriptor(\.scheduledTime))
            .compactMap(ScheduleItem.init)
    }
}

private extension ScheduleItem {
    init?(_ departure: Departure) {
        self.init(
            name: departure.name,
            direction: departure.direction,
            scheduledTime: departure.scheduledTime,
            realTime: departure.realTime
        )
    }
}

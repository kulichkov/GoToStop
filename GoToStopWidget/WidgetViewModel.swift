//
//  WidgetViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import GoToStopAPI

struct WidgetData {
    let name: String
    let from: String
    let to: String
    let times: [String]
}

final class WidgetViewModel: ObservableObject {
    private let userDefaults: UserDefaults?
        
    init() {
        self.userDefaults = UserDefaults(suiteName: "group.kulichkov.GoToStop")
        NetworkManager.shared.apiKey = userDefaults?.string(forKey: "apiKey")
    }
    
    @MainActor
    func getWidgetData() async throws -> WidgetData {
        let departures = try await NetworkManager.shared.getDepartures()
        return mapDepartures(departures)
    }
    
    private func mapDepartures(_ departures: [Departure]) -> WidgetData {
        debugPrint("Processing departures...", departures)
        let firstDeparture = departures.first
        return WidgetData(
            name: firstDeparture?.name ?? "-",
            from: firstDeparture?.stop ?? "-",
            to: firstDeparture?.direction ?? "-",
            times: departures.compactMap { $0.rtTime }
        )
    }
}

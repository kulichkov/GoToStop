//
//  GoToStopWidgetProvider.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import WidgetKit
import GoToStopAPI

struct GoToStopWidgetProvider: AppIntentTimelineProvider {
    func snapshot(for configuration: GoToStopIntent, in context: Context) async -> GoToStopWidgetEntry {
        GoToStopWidgetEntry(
            date: .now,
            data: .preview2,
            widgetUrl: URL(string: UUID().uuidString)
        )
    }
    
    func timeline(for configuration: GoToStopIntent, in context: Context) async -> Timeline<GoToStopWidgetEntry> {
        guard
            let stopLocation = configuration.stopLocation,
            let trips = configuration.trips,
            !trips.isEmpty
        else {
            return .usage
        }
        let widgetProviderHelper = GoToStopWidgetProviderHelper(
            stopLocation: stopLocation,
            trips: trips
        )
        
        do {
            let widgetEntries = try widgetProviderHelper.getWidgetEntries()
            let tenMinutesLater = Date.now.addingTimeInterval(10 * 60)
            return Timeline(
                entries: widgetEntries,
                policy: .after(tenMinutesLater)
            )
        } catch {
            debugPrint(#function, error, "Show widget usage")
            return .usage
        }
    }
    
    func placeholder(in context: Context) -> GoToStopWidgetEntry {
        .init(
            date: .now,
            data: .preview2,
            widgetUrl: URL(string: UUID().uuidString)
        )
    }
}

private extension Timeline<GoToStopWidgetEntry> {
    static let usage = Timeline(
        entries: [.init(date: .now, data: .preview, widgetUrl: nil)],
        policy: .never
    )
}

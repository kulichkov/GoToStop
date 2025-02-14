//
//  GoToStopWidgetProvider.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import WidgetKit
import GoToStopAPI

struct GoToStopWidgetProvider: AppIntentTimelineProvider {
    private var viewModel = GoToStopWidgetViewModel()
    
    func snapshot(for configuration: GoToStopIntent, in context: Context) async -> GoToStopWidgetEntry {
        GoToStopWidgetEntry(
            date: .now,
            data: .preview2,
            stop: .mock(),
            trips: [.mock()]
        )
    }
    
    func timeline(for configuration: GoToStopIntent, in context: Context) async -> Timeline<GoToStopWidgetEntry> {
        do {
            let widgetEntries = try await viewModel.getWidgetEntries(configuration)
            
            let tenMinutesLater = Date.now.addingTimeInterval(10 * 60)
            
            return Timeline(
                entries: widgetEntries,
                policy: .after(tenMinutesLater)
            )
        } catch {
            debugPrint(#function, error, "Show widget usage")
            return Timeline(
                entries: [.init(date: .now, data: .init(updateTime: .now, stop: nil, items: []))],
                policy: .never
            )
        }
    }
    
    func placeholder(in context: Context) -> GoToStopWidgetEntry {
        .init(
            date: .now,
            data: .preview2,
            stop: .mock(),
            trips: [.mock()]
        )
    }
}

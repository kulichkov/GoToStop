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
            data: .preview
        )
    }
    
    func timeline(for configuration: GoToStopIntent, in context: Context) async -> Timeline<GoToStopWidgetEntry> {
        do {
            let widgetEntries = try await viewModel.getWidgetEntries(configuration)
            
            let updatePolicy: TimelineReloadPolicy
            if let date = widgetEntries.last?.date {
                updatePolicy = .after(date)
            } else {
                updatePolicy = .atEnd
            }
            
            let timeline = Timeline(
                entries: widgetEntries,
                policy: updatePolicy
            )
            return timeline
        } catch {
            debugPrint(error)
            return Timeline(
                entries: [.init(date: .now, data: .init(updateTime: .now, stop: nil, items: []))],
                policy: .never
            )
        }
    }
    
    func placeholder(in context: Context) -> GoToStopWidgetEntry {
        .init(
            date: .now,
            data: .preview2
        )
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

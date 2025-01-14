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
            date: Date(),
            data: .preview
        )
    }
    
    func timeline(for configuration: GoToStopIntent, in context: Context) async -> Timeline<GoToStopWidgetEntry> {
        do {
            let widgetEntries = try await viewModel.getWidgetEntries(configuration)
            let timeline = Timeline(
                entries: widgetEntries,
                policy: .atEnd
            )
            return timeline
        } catch {
            debugPrint(error)
            return Timeline(
                entries: [],
                policy: .never
            )
        }
    }
    
    func placeholder(in context: Context) -> GoToStopWidgetEntry {
        .init(
            date: Date(),
            data: GoToStopWidgetData(
                stop: "-",
                items: []
            )
        )
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

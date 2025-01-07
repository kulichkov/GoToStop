//
//  GoToStopWidgetProvider.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import WidgetKit
import GoToStopAPI

struct GoToStopWidgetProvider: TimelineProvider {
    private var viewModel = GoToStopWidgetViewModel()
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (GoToStopWidgetEntry) -> Void) {
        let snapshot = GoToStopWidgetEntry(
            date: Date(),
            data: .preview
        )
        completion(snapshot)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<GoToStopWidgetEntry>) -> Void) {
        Task {
            do {
                let widgetData = try await viewModel.getWidgetData()
                let entry = GoToStopWidgetEntry(
                    date: .now,
                    data: widgetData
                )
                let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(10 * 60)))
                completion(timeline)
            } catch {
                debugPrint(error)
            }
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

//
//  GoToStopWidget.swift
//  GoToStopWidget
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import WidgetKit
import SwiftUI
import GoToStopAPI

struct GoToStopWidget: Widget {
    let kind: String = "kulichkov.GoToStop.GoToStopWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: GoToStopIntent.self,
            provider: GoToStopWidgetProvider()) { entry in
                if entry.stop == nil || entry.trips.isEmpty {
                    GoToStopWidgetUsageView()
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    GoToStopWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                        .widgetURL(entry.makeWidgetUrl())
                }
            }
            .supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemLarge,
            ])
            .onBackgroundURLSessionEvents(
                matching: NetworkManager.shared.backgroundUrlSessionIdentifier
            ) { identifier, completion in
                logger?.info("Some background event happened for session \(identifier)")
                NetworkManager.shared.setBackgroundSessionCompletion(completion) 
            }
    }
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        stop: .mock(),
        trips: [.mock()]
    )
}

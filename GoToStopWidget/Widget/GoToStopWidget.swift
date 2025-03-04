//
//  GoToStopWidget.swift
//  GoToStopWidget
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import WidgetKit
import SwiftUI

struct GoToStopWidget: Widget {
    let kind: String = "kulichkov.GoToStop.GoToStopWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: GoToStopIntent.self,
            provider: GoToStopWidgetProvider.shared) { entry in
                if entry.widgetUrl == nil {
                    GoToStopWidgetUsageView()
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    GoToStopWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                        .widgetURL(entry.widgetUrl)
                }
            }
            .supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge
            ])
    }
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        widgetUrl: URL(string: UUID().uuidString)
    )
}

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
                GoToStopWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
            .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview
    )
    GoToStopWidgetEntry(
        date: .now.addingTimeInterval(160),
        data: .preview
    )
}

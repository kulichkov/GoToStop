//
//  GoToStopWidgetEntryView.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct GoToStopWidgetEntryView: View {
    var entry: GoToStopWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.data.stop)
                Spacer()
                Button(intent: RefreshIntent()) { Text("Refresh") }
            }
            ForEach(entry.data.items.indices.prefix(7), id: \.self) { index in
                HStack {
                    Text(entry.data.items[index].name)
                    Text(entry.data.items[index].direction)
                    Spacer()
                    if let departureTime = entry.data.items[index].realTime ?? entry.data.items[index].scheduledTime {
                        Text(departureTime.formatted(date: .omitted, time: .shortened))
                    }
                }
            }
            
            Spacer()
        }
        .font(.caption)
        .lineLimit(1)
    }
}

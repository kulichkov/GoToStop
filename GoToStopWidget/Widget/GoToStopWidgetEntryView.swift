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
                Text("Updated: \(entry.date.formatted(date: .omitted, time: .shortened))")
                Button(intent: RefreshIntent()) { Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90") }
            }
            ForEach(entry.data.items.indices.prefix(7), id: \.self) { index in
                HStack {
                    Text(entry.data.items[index].name)
                    Text(entry.data.items[index].direction)
                        .truncationMode(.middle)
                    if let minutesLeft = entry.data.items[index].minutesLeft {
                        Spacer()
                        Text("in \(minutesLeft) min")
                    }
                    if let departureTime = entry.data.items[index].time {
                        Spacer()
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

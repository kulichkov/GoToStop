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

    var atTime: String {
        entry.data.updateTime.formatted(date: .omitted, time: .shortened)
    }
    
    var numberOfItems: Int {
        switch entry.widgetFamily {
        case .systemSmall: 2
        case .systemMedium: 2
        default: 6
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            Spacer(minLength: 16)
            tripList
                .padding(.horizontal, -4)
            Spacer()
        }
        .font(.caption2)
    }
    
    var header: some View {
        HStack(alignment: .top) {
            Text(entry.data.stop)
                .lineLimit(2)
                .truncationMode(.head)
            Spacer()
            Button(intent: RefreshIntent()) {
                HStack {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    if entry.widgetFamily != .systemSmall {
                        Text(atTime)
                    }
                }
            }
            .padding(.trailing, -4)
        }
    }
    
    var tripList: some View {
        VStack(spacing: 8) {
            ForEach(entry.data.items.prefix(numberOfItems)) { item in
                tripView(item)
            }
        }
    }
    
    func tripView(_ item: ScheduleItem) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                Spacer()
                Text(item.direction).truncationMode(.head)
            }
            Spacer(minLength: 4)
            HStack {
                if let minutesLeft = item.minutesLeft {
                    Text("in \(minutesLeft) min")
                }
                Spacer()
                if let departureTime = item.time {
                    Text(departureTime.formatted(date: .omitted, time: .shortened))
                }
            }
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.foreground, lineWidth: 1)
        )
    }
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        widgetFamily: .systemSmall,
        data: .preview2
    )
}

#Preview(as: .systemMedium) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        widgetFamily: .systemMedium,
        data: .preview2
    )
}

#Preview(as: .systemLarge) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        widgetFamily: .systemLarge,
        data: .preview2
    )
}

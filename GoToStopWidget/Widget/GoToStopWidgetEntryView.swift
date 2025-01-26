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
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    private var atTime: String {
        entry.data.updateTime.formatted(date: .omitted, time: .shortened)
    }
    
    private var isCompact: Bool {
        widgetFamily == .systemSmall
    }
    
    private var numberOfItems: Int {
        switch widgetFamily {
        case .systemSmall: 2
        case .systemMedium: 2
        default: 6
        }
    }
    
    var body: some View {
        VStack() {
            header
            Spacer().frame(height: 16)
            tripList
                .padding(.horizontal, -4)
        }
        .font(.caption2)
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            if let stop = entry.data.stop {
                Text(stop)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .truncationMode(.head)
            }
            Spacer()
            Button(intent: RefreshIntent()) {
                HStack {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    if !isCompact {
                        Text(atTime)
                    }
                }
            }
            .padding(.trailing, -4)
        }
    }
    
    private var tripList: some View {
        VStack(spacing: 8) {
            ForEach(entry.data.items.prefix(numberOfItems)) { item in
                if isCompact {
                    tripCompactView(item)
                } else {
                    tripView(item)
                }
            }
            Spacer()
        }
    }
    
    private func tripView(_ item: ScheduleItem) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                Spacer()
                Text("→")
                Text(item.direction).truncationMode(.head)
            }
            Spacer().frame(height: 2)
            HStack {
                if let minutesLeft = item.minutesLeft {
                    Text("in \(minutesLeft) min")
                }
                Spacer()
                if item.isCancelled {
                    Text("Cancelled")
                        .strikethrough(false)
                        .foregroundStyle(.red)
                }
                
                if item.timeDiffers, let realTime = item.realTime {
                    Text("Actual: " + realTime.formatted(date: .omitted, time: .shortened))
                }
                if let scheduledTime = item.scheduledTime {
                    Text("Scheduled: " + scheduledTime.formatted(date: .omitted, time: .shortened))
                        .foregroundStyle(item.timeDiffers ? .secondary : .primary)
                }
            }
            .strikethrough(item.isCancelled)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.foreground, lineWidth: 1)
        )
    }
    
    private func tripCompactView(_ item: ScheduleItem) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                Spacer()
                Text(item.direction).truncationMode(.head)
            }
            Spacer().frame(height: 2)
            HStack {
                if let minutesLeft = item.minutesLeft {
                    Text("in \(minutesLeft) min")
                }
                Spacer()
                if item.isCancelled {
                    Text("⊗")
                        .strikethrough(false)
                        .foregroundStyle(.red)
                }
                if let departureTime = item.time {
                    Text(departureTime.formatted(date: .omitted, time: .shortened))
                }
            }
            .strikethrough(item.isCancelled)
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
        data: .preview2
    )
}

#Preview(as: .systemMedium) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2
    )
}

#Preview(as: .systemLarge) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2
    )
}


struct GoToStopWidgetUsageView: View {
    var body: some View {
        Text("Please edit the widget to specify a stop, trips and directions")
            .multilineTextAlignment(.center)
    }
}

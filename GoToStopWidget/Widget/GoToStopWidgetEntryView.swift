//
//  GoToStopWidgetEntryView.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import SwiftUI
import WidgetKit

struct GoToStopWidgetEntryView: View {
    var entry: GoToStopWidgetProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    private var atTime: String {
        entry.data.updateTime.formatted(date: .omitted, time: .shortened)
    }
    
    private var isCompact: Bool {
        widgetFamily == .systemSmall
    }
    
    private var isExtraLarge: Bool {
        widgetFamily == .systemExtraLarge
    }
    
    private var numberOfItems: Int {
        switch widgetFamily {
        case .systemSmall: 2
        case .systemMedium: 2
        case .systemLarge: 6
        case .systemExtraLarge: 12
        default: 6
        }
    }
    
    private var items: [ScheduleItem] {
        Array(entry.data.items.prefix(numberOfItems))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                    .widgetAccentable()
                Spacer().frame(height: 8)
                if isExtraLarge {
                    makeTripGrid(items: items)
                } else {
                    makeTripList(items: items)
                }
            }
            .font(.caption2)
            .frame(height: geometry.size.height, alignment: .top)
        }
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            if let stop = entry.data.stop {
                Text(stop)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .truncationMode(.head)
                    .padding(.leading, 8)
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
        }
    }
    
    private func makeTripList(items: [ScheduleItem]) -> some View {
        VStack(spacing: 8) {
            ForEach(items) { item in
                if isCompact {
                    tripCompactView(item)
                } else {
                    tripView(item)
                }
            }
            Spacer()
        }
    }
    
    private func makeTripGrid(items: [ScheduleItem]) -> some View {
        let leftItems = Array(items.prefix(numberOfItems/2))
        let rightItems = Array(items.dropFirst(numberOfItems/2))
        
        return HStack(alignment: .top, spacing: 16) {
            makeTripList(items: leftItems)
            if rightItems.isEmpty {
                Spacer().frame(width: .infinity)
            } else {
                makeTripList(items: rightItems)
            }
        }
    }
    
    private func tripView(_ item: ScheduleItem) -> some View {
        ZStack {
            Color(UIColor.gray.withAlphaComponent(0.2))
                .widgetAccentable()
            
            VStack(alignment: .leading) {
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("→")
                    Text(item.direction).truncationMode(.head)
                }
                Spacer().frame(height: 4)
                HStack {
                    if
                        let time = item.time,
                        let relatedTime = item.relatedTime,
                        let timeLeft = relatedTime.shortTime(to: time)
                    {
                        Text("in \(timeLeft)")
                            .foregroundStyle(.green)
                            .brightness(-0.2)
                    }
                    Spacer()
                    if item.isCancelled {
                        Text("Cancelled")
                            .strikethrough(false)
                            .foregroundStyle(.red)
                    } else if !item.isReachable {
                        Text("!")
                            .strikethrough(false)
                            .foregroundStyle(.red)
                    }
                    
                    if item.timeDiffers, let realTime = item.realTime {
                        Text("Actual: " + realTime.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(.orange)
                            .brightness(-0.2)
                    }
                    if let scheduledTime = item.scheduledTime {
                        Text("Scheduled: " + scheduledTime.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(item.timeDiffers ? .secondary : .primary)
                    }
                    if item.hasWarnings {
                        Text("Warning")
                            .foregroundStyle(.orange)
                            .strikethrough(false)
                    }
                }
                .strikethrough(item.isCancelled)
            }
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .fixedSize(horizontal: false, vertical: true)
        .cornerRadius(8)
    }
    
    private func tripCompactView(_ item: ScheduleItem) -> some View {
        ZStack {
            Color(UIColor.gray.withAlphaComponent(0.2))
                .widgetAccentable()

            VStack(alignment: .leading) {
                HStack {
                    Text(item.name)
                    Spacer()
                    Text(item.direction).truncationMode(.head)
                }
                Spacer().frame(height: 4)
                HStack {
                    if
                        let time = item.time,
                        let relatedTime = item.relatedTime,
                        let timeLeft = relatedTime.abbreviatedTime(to: time)
                    {
                        Text("\(timeLeft)")
                            .foregroundStyle(.green)
                            .brightness(-0.2)
                    }
                    Spacer()
                    if item.isCancelled {
                        Image(systemName: "xmark.circle")
                            .strikethrough(false)
                            .foregroundStyle(.red)
                    } else if !item.isReachable {
                        Text("!")
                            .strikethrough(false)
                            .foregroundStyle(.red)
                    }
                    if let departureTime = item.time {
                        Text(departureTime.formatted(date: .omitted, time: .shortened))
                    }
                    if item.hasWarnings {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .strikethrough(false)
                    }
                }
                .strikethrough(item.isCancelled)
            }
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .fixedSize(horizontal: false, vertical: true)
        .cornerRadius(8)
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

#Preview(as: .systemMedium) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        widgetUrl: URL(string: UUID().uuidString)
    )
}

#Preview(as: .systemLarge) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        widgetUrl: URL(string: UUID().uuidString)
    )
}

#Preview(as: .systemExtraLarge) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        widgetUrl: URL(string: UUID().uuidString)
    )
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .init(updateTime: .now, stop: "Kuhwaldstraße", items: []),
        widgetUrl: URL(string: UUID().uuidString)
    )
}


struct GoToStopWidgetUsageView: View {
    var body: some View {
        Text("Please edit the widget to specify a stop, trips and directions")
            .multilineTextAlignment(.center)
    }
}

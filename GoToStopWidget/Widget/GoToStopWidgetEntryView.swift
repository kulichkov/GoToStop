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
    
    private var numberOfItems: Int {
        switch widgetFamily {
        case .systemSmall: 2
        case .systemMedium: 2
        default: 6
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                Spacer().frame(height: 8)
                tripList
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
            Spacer().frame(height: 4)
            HStack {
                if let minutesLeft = item.minutesLeft {
                    Text("in \(minutesLeft) min")
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
            }
            .strikethrough(item.isCancelled)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(8)
    }
    
    private func tripCompactView(_ item: ScheduleItem) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                Spacer()
                Text(item.direction).truncationMode(.head)
            }
            Spacer().frame(height: 4)
            HStack {
                if let minutesLeft = item.minutesLeft {
                    Text("in \(minutesLeft) min")
                        .foregroundStyle(.green)
                        .brightness(-0.2)
                }
                Spacer()
                if item.isCancelled {
                    Text("⊗")
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
            }
            .strikethrough(item.isCancelled)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(8)
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

#Preview(as: .systemMedium) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        stop: .mock(),
        trips: [.mock()]
    )
}

#Preview(as: .systemLarge) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .preview2,
        stop: .mock(),
        trips: [.mock()]
    )
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopWidgetEntry(
        date: .now,
        data: .init(updateTime: .now, stop: "Kuhwaldstraße", items: []),
        stop: .mock(),
        trips: [.mock()]
    )
}


struct GoToStopWidgetUsageView: View {
    var body: some View {
        Text("Please edit the widget to specify a stop, trips and directions")
            .multilineTextAlignment(.center)
    }
}

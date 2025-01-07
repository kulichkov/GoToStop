//
//  GoToStopWidget.swift
//  GoToStopWidget
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import WidgetKit
import SwiftUI
import GoToStopAPI

struct Provider: TimelineProvider {
    private var viewModel = WidgetViewModel()
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (GoToStopEntry) -> Void) {
        let snapshot = GoToStopEntry(
            date: Date(),
            data: .preview
        )
        completion(snapshot)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<GoToStopEntry>) -> Void) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration, nextTramTime: entryDate.addingTimeInterval(5 * 60))
//            entries.append(entry)
//        }
//        return Timeline(entries: entries, policy: .atEnd)
        
        Task {
            do {
                let widgetData = try await viewModel.getWidgetData()
                let entry = GoToStopEntry(
                    date: .now,
                    data: widgetData
                )
                let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(5 * 60)))
                completion(timeline)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private let dateFormatter = DateFormatter()
    
    func placeholder(in context: Context) -> GoToStopEntry {
        GoToStopEntry(
            date: Date(),
            data: WidgetData(
                stop: "-",
                items: []
            )
        )
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct GoToStopEntry: TimelineEntry {
    let date: Date
    
    let data: WidgetData
}

struct GoToStopWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.data.stop)
            ForEach(entry.data.items.indices.prefix(8), id: \.self) { index in
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

struct GoToStopWidget: Widget {
    let kind: String = "GoToStopWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GoToStopWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GoToStopWidget()
} timeline: {
    GoToStopEntry(
        date: .now,
        data: .preview
    )
    GoToStopEntry(
        date: .now.addingTimeInterval(160),
        data: .preview
    )
}

extension WidgetData {
    static let preview = WidgetData(
        stop: "Kuhwaldstr.",
        items: [
            .init(
                name: "Tram 17",
                direction: "Somewhere 1",
                scheduledTime: .now,
                realTime: nil
            ),
            .init(
                name: "Tram 17",
                direction: "Somewhere 2",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: nil
            )
        ])
}

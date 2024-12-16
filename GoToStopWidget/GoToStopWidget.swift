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
                name: "-",
                from: "-",
                to: "-",
                times: []
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
            Text(entry.data.name)
            HStack(alignment: .firstTextBaseline) {
                Text("Time:")
                Text(entry.date, style: .time)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline) {
                Text("From:")
                Text(entry.data.from)
                    .truncationMode(.head)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline) {
                Text("To:")
                Text(entry.data.to)
                    .truncationMode(.head)
                Spacer()
            }
            
            ForEach(entry.data.times.indices.prefix(4), id: \.self) { index in
                Text(entry.data.times[index])
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
        name: "Tram 17",
        from: "Stop 1 Stop 1 Stop 1 Stop 1 Stop 1 Stop 1",
        to: "Stop 2 Stop 2 Stop 2 Stop 2 Stop 2 Stop 2",
        times: [
            "11:11:11",
            "22:22:22",
        ]
    )
}

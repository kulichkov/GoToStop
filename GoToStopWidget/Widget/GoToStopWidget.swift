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
            provider: GoToStopWidgetProvider.shared) { entry in
                if entry.widgetUrl == nil {
                    GoToStopWidgetUsageView()
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    GoToStopWidgetEntryView(
                        entry: entry,
                        refreshIntent: .init(widgetHash: entry.widgetUrl?.widgetHash)
                    )
                        .containerBackground(.fill.tertiary, for: .widget)
                        .widgetURL(entry.widgetUrl)
                }
            }
            .supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemLarge,
            ])
            .onBackgroundURLSessionEvents(
                matching: NetworkManager.shared.backgroundUrlSessionIdentifier
            ) { identifier, completion in
                logger?.info("Some background event happened for session \(identifier)")
                NetworkManager.shared.setBackgroundSessionCompletion(completion) 
            }
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

private extension URL {
    var widgetHash: String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            logger?.error("Couldn't make components from the url")
            return nil
        }
        guard let queryItems = urlComponents.queryItems, !queryItems.isEmpty else {
            logger?.error("Couldn't get query items from the url")
            return nil
        }
        guard let stopString = queryItems.first(where: { $0.name == "stop" })?.value else {
            logger?.error("Couldn't get stop string from a query item")
            return nil
        }
        
        let stopComponents = stopString.split(separator: "#")
        
        guard stopComponents.count == 2 else {
            logger?.error("Stop string \(stopString) doesn't have all stop components")
            return nil
        }
        
        let locationId = stopComponents[0]
        
        let trips = queryItems
            .filter{ $0.name == "trip" }
            .compactMap(\.value)
            .compactMap(Trip.init)
        
        let tripsString = trips
            .sorted(using: SortDescriptor(\.lineId))
            .map { $0.lineId + $0.directionId }
            .joined()
        
        return String(locationId + tripsString).sha256
    }
}

//
//  GoToStopWidgetEntry.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import Foundation
import WidgetKit

struct GoToStopWidgetEntry: TimelineEntry {
    let date: Date
    let data: GoToStopWidgetData
    let widgetUrl: URL?
    
    init(
        date: Date,
        data: GoToStopWidgetData,
        widgetUrl: URL? = nil
    ) {
        self.date = date
        self.data = data
        self.widgetUrl = widgetUrl
    }
}

extension GoToStopWidgetEntry {
    var widgetHash: String? {
        return widgetUrl?.widgetHash
    }
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

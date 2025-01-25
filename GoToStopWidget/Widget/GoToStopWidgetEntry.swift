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
    let stop: StopLocation?
    let trips: [Trip]
    
    init(
        date: Date,
        data: GoToStopWidgetData,
        stop: StopLocation? = nil,
        trips: [Trip] = []
    ) {
        self.date = date
        self.data = data
        self.stop = stop
        self.trips = trips
    }
}

extension GoToStopWidgetEntry {
    func makeWidgetUrl() -> URL? {
        var components = URLComponents()
        components.scheme = "gotostop"
        components.host = "widget"
        
        let stopQueryItem = stop.map { URLQueryItem(name: "stop", value: $0.id) }
        
        let tripsQueryItems = trips.map {
            URLQueryItem(name: "trip", value: $0.id)
        }
        let optionalItems = [stopQueryItem] + tripsQueryItems
        
        components.queryItems = optionalItems.compactMap { $0 }

        return components.url
    }
}

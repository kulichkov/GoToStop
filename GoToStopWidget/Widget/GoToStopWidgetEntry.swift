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

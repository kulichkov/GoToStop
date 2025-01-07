//
//  GoToStopWidgetData.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 07.01.25.
//

import Foundation

struct ScheduleItem: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let scheduledTime: Date?
    let realTime: Date?
}

struct GoToStopWidgetData {
    let stop: String
    let items: [ScheduleItem]
}

extension GoToStopWidgetData {
    static let preview = GoToStopWidgetData(
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

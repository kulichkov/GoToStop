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
    let time: Date?
    let minutesLeft: UInt?
}

struct ScheduledTrip: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let scheduledTime: Date?
    let realTime: Date?
}

extension ScheduledTrip {
    var time: Date? { realTime ?? scheduledTime }
}

struct GoToStopWidgetData {
    let updateTime: Date
    let stop: String
    let items: [ScheduleItem]
}

extension GoToStopWidgetData {
    static let preview = GoToStopWidgetData(
        updateTime: .now.addingTimeInterval(-600),
        stop: "Kuhwaldstr.",
        items: [
            .init(
                name: "Tram 17",
                direction: "Somewhere 1",
                time: .now,
                minutesLeft: .zero
            ),
            .init(
                name: "Tram 17",
                direction: "Somewhere 2",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10
            )
        ])
}

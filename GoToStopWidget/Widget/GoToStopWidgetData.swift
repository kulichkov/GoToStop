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
    let isReachable: Bool
    let isCancelled: Bool
}

struct ScheduledTrip: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let isCancelled: Bool
    let isReachable: Bool
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
        stop: "Frankfurt (Main) Kuhwaldstraße",
        items: [
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Rebstockbad",
                time: .now,
                minutesLeft: .zero,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Rebstockbad",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            )
        ])
    
    static let preview2 = GoToStopWidgetData(
        updateTime: .now.addingTimeInterval(-600),
        stop: "Frankfurt (Main) Leonardo-da-Vinci-Allee",
        items: [
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now,
                minutesLeft: 10,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now,
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now,
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                time: .now.addingTimeInterval(600),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
        ])
}

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
    let minutesLeft: UInt?
    let isReachable: Bool
    let isCancelled: Bool
    var time: Date? { realTime ?? scheduledTime }
    var timeDiffers: Bool {
        guard let realTime, let scheduledTime else { return false }
        return realTime != scheduledTime
    }
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
                scheduledTime: .now,
                realTime: .now.addingTimeInterval(120),
                minutesLeft: .zero,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Rebstockbad",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
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
                scheduledTime: .now,
                realTime: nil,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                minutesLeft: 10,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now,
                realTime: nil,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                minutesLeft: 10,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now,
                realTime: nil,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                minutesLeft: 10,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now,
                realTime: nil,
                minutesLeft: .zero,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                minutesLeft: 10,
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                minutesLeft: 10,
                isReachable: true,
                isCancelled: false
            ),
        ])
}

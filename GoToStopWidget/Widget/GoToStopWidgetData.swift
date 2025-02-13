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
    let relatedTime: Date?
    let isReachable: Bool
    let isCancelled: Bool
    let hasWarnings: Bool
    var time: Date? { realTime ?? scheduledTime }
    var timeDiffers: Bool {
        guard let realTime, let scheduledTime else { return false }
        return realTime != scheduledTime
    }
    
    init(
        name: String,
        direction: String,
        scheduledTime: Date?,
        realTime: Date?,
        relatedTime: Date?,
        isReachable: Bool,
        isCancelled: Bool,
        hasWarnings: Bool = false
    ) {
        self.name = name
        self.direction = direction
        self.scheduledTime = scheduledTime
        self.realTime = realTime
        self.relatedTime = relatedTime
        self.isReachable = isReachable
        self.isCancelled = isCancelled
        self.hasWarnings = hasWarnings
    }
}

struct ScheduledTrip: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let isCancelled: Bool
    let isReachable: Bool
    let hasWarnings: Bool
    let scheduledTime: Date?
    let realTime: Date?
}

extension ScheduledTrip {
    var time: Date? { realTime ?? scheduledTime }
}

struct GoToStopWidgetData {
    let updateTime: Date
    let stop: String?
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
                relatedTime: .now,
                isReachable: false,
                isCancelled: true,
                hasWarnings: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Rebstockbad",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false,
                hasWarnings: true
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
                relatedTime: .now,
                isReachable: false,
                isCancelled: false,
                hasWarnings: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: false,
                isCancelled: true,
                hasWarnings: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now,
                realTime: nil,
                relatedTime: .now,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now,
                realTime: nil,
                relatedTime: .now,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now,
                realTime: nil,
                relatedTime: .now,
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(120),
                realTime: .now.addingTimeInterval(180),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: false,
                isCancelled: true
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(600),
                realTime: .now.addingTimeInterval(780),
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
            .init(
                name: "Tram 17",
                direction: "Frankfurt (Main) Neu-Isenburg Stadtgrenze",
                scheduledTime: .now.addingTimeInterval(660),
                realTime: nil,
                relatedTime: .now.addingTimeInterval(600),
                isReachable: true,
                isCancelled: false
            ),
        ])
}

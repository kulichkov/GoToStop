//
//  ScheduleItem.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 09.02.25.
//

import Foundation
import GoToStopCore

struct ScheduleItem: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let scheduledTime: Date?
    let realTime: Date?
    let isReachable: Bool
    let isCancelled: Bool
    let messages: [Message]
    var activeMessages: [Message] { messages.filter(\.isActive) }
    var time: Date? { realTime ?? scheduledTime }
    var minutesLeft: String? {
        guard let time else { return nil }
        return Date.now.fullTime(to: time)
    }
    var timeDiffers: Bool {
        guard let realTime, let scheduledTime else { return false }
        return realTime != scheduledTime
    }
}

extension ScheduleItem {
    init?(_ departure: Departure) {
        self.init(
            name: departure.name,
            direction: departure.direction,
            scheduledTime: departure.scheduledTime,
            realTime: departure.realTime,
            isReachable: departure.isReachable,
            isCancelled: departure.isCancelled,
            messages: departure.messages
        )
    }
}

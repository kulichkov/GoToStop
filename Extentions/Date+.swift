//
//  Date+.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 13.02.25.
//

import Foundation

extension Date {
    func fullTime(to date: Date) -> String? {
        DateComponentsFormatter.fullDaysHoursMinutes.string(from: self, to: date)
    }
    
    func shortTime(to date: Date) -> String? {
        DateComponentsFormatter.shortDaysHoursMinutes.string(from: self, to: date)
    }
    
    func abbreviatedTime(to date: Date) -> String? {
        DateComponentsFormatter.abbreviatedDaysHoursMinutes.string(from: self, to: date)
    }
}

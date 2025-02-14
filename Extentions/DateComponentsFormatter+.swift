//
//  DateComponentsFormatter+.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 13.02.25.
//

import Foundation

extension DateComponentsFormatter {
    static let fullDaysHoursMinutes: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .full
        return formatter
    }()
    
    static let abbreviatedDaysHoursMinutes: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    static let shortDaysHoursMinutes: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()
}

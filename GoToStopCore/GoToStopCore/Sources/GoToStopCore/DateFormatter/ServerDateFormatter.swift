//
//  ServerDateFormatter.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

import Foundation

public enum ServerDateFormatter {
    private static let serverDateTimeFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
        
    public static func date(date: String?, time: String?) -> Date? {
        guard let date, let time else { return nil }
        return serverDateTimeFormatter.date(from: "\(date) \(time)")
    }
}

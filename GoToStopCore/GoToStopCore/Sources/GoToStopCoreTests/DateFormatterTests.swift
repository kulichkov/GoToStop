//
//  DateFormatterTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 08.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

struct DateFormatterTests {

    @Test
    func testServerDateFormatter() {
        let date0 = ServerDateFormatter.date(date: "2025-03-03", time: "13:21:00")
        let currentZoneGMTOffset = TimeInterval(TimeZone.current.secondsFromGMT())
        
        #expect(date0 == Date(timeIntervalSince1970: 1741008060 - currentZoneGMTOffset))
        
        let date1 = ServerDateFormatter.date(date: nil, time: "13:21:00")
        
        #expect(date1 == nil)
        
        let date2 = ServerDateFormatter.date(date: "2025-03-03", time: nil)
        
        #expect(date2 == nil)
    }

}

//
//  TransportCategoryTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 09.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore
import CoreLocation

struct TransportCategoryTests {
    
    @Test
    func emoji() {
        #expect(TransportCategory.bus.emoji == "🚍")
        #expect(TransportCategory.ice.emoji == "🚆")
        #expect(TransportCategory.s.emoji == "🚆")
        #expect(TransportCategory.tram.emoji == "🚊")
        #expect(TransportCategory.u.emoji == "🚇")
        #expect(TransportCategory.rb.emoji == "🚆")
        #expect(TransportCategory.re.emoji == "🚆")
        #expect(TransportCategory.ec.emoji == "🚆")
        #expect(TransportCategory.unknown.emoji == "🚏")
    }
    
}

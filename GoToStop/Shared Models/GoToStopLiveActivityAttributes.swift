//
//  GoToStopLiveActivityAttributes.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 16.01.25.
//

import ActivityKit

struct GoToStopLiveActivityAttributes: ActivityAttributes {
    public struct TripItem: Identifiable, Codable, Hashable {
        let id: String
        let name: String
        let direction: String
        let minutesLeft: UInt
    }
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        let trips: [TripItem]
    }

    // Fixed non-changing properties about your activity go here!
    var stopName: String
}

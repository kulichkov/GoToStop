//
//  GoToStopWidgetLiveActivity.swift
//  GoToStopWidget
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GoToStopWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GoToStopLiveActivityAttributes.self) { context in
            let stopName = context.attributes.stopName
            let trips = context.state.trips
            
            // Lock screen/banner UI goes here
            VStack {
                Text("\(stopName):")
                ForEach(trips) { trip in
                    HStack {
                        Text(trip.name)
                        Spacer()
                        Text(trip.direction)
                        Spacer()
                        Text("\(trip.minutesLeft)")
                    }
                }
            }
            .font(.caption2)
            .padding()
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            let stopName = context.attributes.stopName
            let closestTrip = context.state.trips.first
            let closestTripName = closestTrip?.name
            let closestTripShortName = closestTripName?.split(separator: " ").last
            let closestTripMinutes = closestTrip?.minutesLeft
            
            let restTrips = context.state.trips.dropFirst()
            
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    if let closestTripName {
                        Text(closestTripName)
                            .padding(.horizontal)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let closestTripMinutes {
                        Text("in \(closestTripMinutes) min")
                            .padding(.horizontal)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text("\(stopName):")
                        ForEach(restTrips) { trip in
                            HStack {
                                Text(trip.name)
                                Spacer()
                                Text("in \(trip.minutesLeft) min")
                            }
                        }
                    }
                }
            } compactLeading: {
                if let closestTripShortName {
                    Text(closestTripShortName)
                }
            } compactTrailing: {
                if let closestTripMinutes {
                    Text("\(closestTripMinutes)")
                }
            } minimal: {
                if let trip = context.state.trips.first {
                    Text("\(trip.minutesLeft)")
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GoToStopLiveActivityAttributes {
    fileprivate static var preview: GoToStopLiveActivityAttributes {
        GoToStopLiveActivityAttributes(stopName: "F Kuhwaldstraße")
    }
}

extension GoToStopLiveActivityAttributes.ContentState {
    fileprivate static var trams: GoToStopLiveActivityAttributes.ContentState {
        GoToStopLiveActivityAttributes.ContentState(
            trips: [
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 4
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 14
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 24
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 34
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 44
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 54
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tram 17",
                    direction: "Frankfurt (Main) Rebstockbad",
                    minutesLeft: 64
                ),
            ]
        )
     }
}

#Preview("Notification", as: .content, using: GoToStopLiveActivityAttributes.preview) {
   GoToStopWidgetLiveActivity()
} contentStates: {
    GoToStopLiveActivityAttributes.ContentState.trams
}

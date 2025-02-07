//
//  GoToStopApp.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import SwiftUI
import struct GoToStopAPI.StopLocation
import struct GoToStopAPI.Trip
import enum GoToStopAPI.TransportCategory

struct StopScheduleParameters {
    let stopLocation: StopLocation
    let tripItems: [TripItem]
}

@main
struct GoToStopApp: App {
    @State var stopScheduleParameters: StopScheduleParameters? {
        didSet {
            goToStopSchedule = stopScheduleParameters != nil
        }
    }
    @State var goToStopSchedule: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let stopScheduleParameters {
                    StopDetailsView(viewModel: .init(stopScheduleParameters))
                } else {
                    WelcomeView()
                        .onOpenURL(perform: handleUrl)
                }
            }
        }
    }
    
    private func handleUrl(_ url: URL) {
        debugPrint(#function)
        self.stopScheduleParameters = url.getStopScheduleParameters()
        let url = try? LogExporter().getLogs()
        debugPrint(#function)
    }
}

extension URL {
    func getStopScheduleParameters() -> StopScheduleParameters? {
        debugPrint(#function, "URL: ", self)
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            debugPrint(#function, "Couldn't make components from the url")
            return nil
        }
        guard let queryItems = urlComponents.queryItems, !queryItems.isEmpty else {
            debugPrint(#function, "Couldn't get query items from the url")
            return nil
        }
        guard let stopString = queryItems.first(where: { $0.name == "stop" })?.value else {
            debugPrint(#function, "Couldn't get stop string from a query item")
            return nil
        }
        
        let stopComponents = stopString.split(separator: "#")
        
        guard stopComponents.count == 2 else {
            debugPrint(#function, "Stop string \(stopString) doesn't have all stop components")
            return nil
        }
        
        let locationId = stopComponents[0]
        let locationName = stopComponents[1]
        
        let stop = StopLocation(
            locationId: String(locationId),
            name: String(locationName)
        )
        
        let trips = queryItems
            .filter{ $0.name == "trip" }
            .compactMap(\.value)
            .compactMap(Trip.init)
        
        debugPrint(#function, "Stop location to use:", stop)
        debugPrint(#function, "trips to use:", trips)
        
        let tripItems: [TripItem] = trips.map { trip in
            TripItem(trip: .init(
                category: trip.category,
                lineId: trip.lineId,
                name: trip.name,
                direction: trip.direction,
                directionId: trip.directionId
            ))
        }
        
        return StopScheduleParameters(
            stopLocation: stop,
            tripItems: tripItems
        )
    }
}

private extension Trip {
    init?(_ string: String) {
        let tripComponents = string.split(separator: "#")
        guard tripComponents.count == 5 else {
            debugPrint(#function, "Trip string \(string) doesn't have all 5 trip components")
            return nil
        }
        guard let category = TransportCategory(rawValue: String(tripComponents[2])) else {
            debugPrint(#function, "\(tripComponents[2]) is not a proper transport category")
            return nil
        }
        
        self.init(
            name: String(tripComponents[0]),
            direction: String(tripComponents[1]),
            category: category,
            lineId: String(tripComponents[3]),
            directionId: String(tripComponents[4])
        )
    }
}

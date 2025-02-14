//
//  GoToStopApp.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import Foundation
import SwiftUI
import GoToStopAPI

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
    @State var goToDebugMenu: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VStack {
                    if let stopScheduleParameters {
                        StopScheduleView(viewModel: .init(stopScheduleParameters))
                    } else {
                        WelcomeView()
                            .onOpenURL(perform: handleUrl)
                    }
                }
                .navigationDestination(isPresented: $goToDebugMenu) {
                    if #available(iOS 18.0, *) {
                        DebugMenuView(viewModel: DebugMenuViewModel())
                    } else {
                        Text("iOS 18.0 or later is required for debugging")
                    }
                }
            }
            .onTapGesture(count: 5) {
                logger?.info("Go to debug menu")
                goToDebugMenu = true
            }
        }
    }
    
    private func handleUrl(_ url: URL) {
        logger?.info("Handler url: \(url)")
        self.stopScheduleParameters = url.getStopScheduleParameters()
        logger?.info("Stop schedule parameters received: \(String(describing: stopScheduleParameters))")
    }
}

extension URL {
    func getStopScheduleParameters() -> StopScheduleParameters? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            logger?.error("Couldn't make components from the url")
            return nil
        }
        guard let queryItems = urlComponents.queryItems, !queryItems.isEmpty else {
            logger?.error("Couldn't get query items from the url")
            return nil
        }
        guard let stopString = queryItems.first(where: { $0.name == "stop" })?.value else {
            logger?.error("Couldn't get stop string from a query item")
            return nil
        }
        
        let stopComponents = stopString.split(separator: "#")
        
        guard stopComponents.count == 2 else {
            logger?.error("Stop string \(stopString) doesn't have all stop components")
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
        
        logger?.info("Stop location to use: \(String(describing: stop))")
        logger?.info("Trips to use: \(String(describing: trips))")
        
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
            logger?.error("Trip string \(string) doesn't have all 5 trip components")
            return nil
        }
        guard let category = TransportCategory(rawValue: String(tripComponents[2])) else {
            logger?.error("\(tripComponents[2]) is not a proper transport category")
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

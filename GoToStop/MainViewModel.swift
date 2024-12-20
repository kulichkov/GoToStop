//
//  MainViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation
import GoToStopAPI

final class MainViewModel: ObservableObject {
    @Published
    private(set) var testSucceeded: Bool?
    @Published
    private(set) var apiKey = Settings.shared.apiKey
    @Published
    private(set) var stopText = ""
    
    @Published
    var newApiKeyText = ""
    
//    func getDepartures() {
//        Task { @MainActor in
//            do {
//                let departures = try await NetworkManager.shared.getDepartures(stopId: <#String#>)
//                debugPrint(departures)
//                testSucceeded = true
//            } catch {
//                debugPrint(error)
//                testSucceeded = false
//            }
//        }
//    }

    func getStops() {
        Task { @MainActor in
            do {
                let stops = try await NetworkManager.shared.getStopLocations(input: "Kuhwaldstrasse")
                debugPrint(stops)
                testSucceeded = true
            } catch {
                debugPrint(error)
                testSucceeded = false
            }
        }
    }
    
    func setApiKey() {
        let newApiKey = newApiKeyText
        Settings.shared.apiKey = newApiKey
        self.apiKey = newApiKey
    }

}

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
    private(set) var apiKey: String?
    @Published
    private(set) var stopText = ""
    
    @Published
    var newApiKeyText = ""


    private let userDefaults: UserDefaults?
    private let userDefaultsApiKey = "apiKey"
        
    init() {
        self.userDefaults = UserDefaults(suiteName: "group.kulichkov.GoToStop")
        let apiKey = userDefaults?.string(forKey: userDefaultsApiKey)
        self.apiKey = apiKey
        NetworkManager.shared.apiKey = apiKey
    }
    
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
        userDefaults?.set(newApiKey, forKey: userDefaultsApiKey)
        self.apiKey = newApiKey
        NetworkManager.shared.apiKey = newApiKey
    }

}

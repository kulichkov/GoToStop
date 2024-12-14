//
//  MainViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation
import GoToStopAPI

final class MainViewModel: ObservableObject {
    private let userDefaultsApiKey = "apiKey"
    @Published var testSucceeded: Bool?
    @Published var apiKey: String?
        
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: userDefaultsApiKey)
        NetworkManager.shared.apiKey = apiKey
    }
    
    func getDepartures() {
        Task { @MainActor in
            do {
                let departures = try await NetworkManager.shared.getDepartures()
                debugPrint(departures)
                testSucceeded = true
            } catch {
                debugPrint(error)
                testSucceeded = false
            }
        }
    }
    
    func setApiKey(_ apiKey: String?) {
        UserDefaults.standard.set(apiKey, forKey: userDefaultsApiKey)
        self.apiKey = apiKey
        NetworkManager.shared.apiKey = apiKey
    }

}

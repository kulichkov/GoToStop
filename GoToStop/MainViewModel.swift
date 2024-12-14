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
    
    @Published var apiKey: String?
        
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: userDefaultsApiKey)
    }
    
    func getDepartures() {
        Task {
            do {
                let departures = try await NetworkManager.shared.getDepartures()
                debugPrint(departures)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func setApiKey(_ apiKey: String?) {
        UserDefaults.standard.set(apiKey, forKey: userDefaultsApiKey)
        self.apiKey = apiKey
    }

}

//
//  MainViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation
import GoToStopAPI
import Combine

struct TripInfo: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
}

final class MainViewModel: ObservableObject {
    @Published private(set) var testSucceeded: Bool?
    @Published private(set) var apiKey = Settings.shared.apiKey
    @Published private(set) var selectedStop = ""
    @Published private(set) var selectedTrips: [TripInfo] = []
    @Published private(set) var isStopSelected = false
    @Published var isSelectingStop = false
    @Published var isSelectingTrips = false
    @Published var newApiKeyText = ""
    
    private var savedTrips: [Trip] = [] {
        didSet {
            selectedTrips = savedTrips.map { TripInfo(
                name: $0.name,
                direction: $0.direction
            ) }
        }
    }
    
    private var binding = Set<AnyCancellable>()
    
    init() {
        refresh()
        bind()
    }

    func refresh() {
        if let name = Settings.shared.stopLocation?.name {
            selectedStop = "Stop: " + name
            isStopSelected = true
        } else {
            selectedStop = "Select stop"
            isStopSelected = false
        }
        
        savedTrips = Settings.shared.trips
    }
    
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

    private func bind() {
        $isSelectingStop
            .merge(with: $isSelectingTrips)
            .filter { $0 == false }
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &binding)
    }
}

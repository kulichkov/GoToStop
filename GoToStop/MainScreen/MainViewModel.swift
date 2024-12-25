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

struct ScheduleItem: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let minutesTillDeparture: String
}

final class MainViewModel: ObservableObject {
    @Published private(set) var apiKey = Settings.shared.apiKey
    @Published private(set) var selectedStop = ""
    @Published private(set) var selectedTrips: [TripInfo] = []
    @Published private(set) var isStopSelected = false
    @Published var isSelectingStop = false
    @Published var isSelectingTrips = false
    @Published var newApiKeyText = ""
    
    @Published private(set) var scheduleItems: [ScheduleItem] = [] {
        didSet {
            fetchingScheduleTask?.cancel()
            fetchingScheduleTask = nil
        }
    }
    
    private var savedTrips: [Trip] = [] {
        didSet {
            selectedTrips = savedTrips.map { TripInfo(
                name: $0.name,
                direction: $0.direction
            ) }
        }
    }
    
    private var fetchingScheduleTask: Task<Void, Never>? {
        didSet {
            if fetchingScheduleTask == nil {
                debugPrint("==== fetching task deleted")
            } else {
                debugPrint("==== fetching task started")
            }
        }
    }
    
    private var binding = Set<AnyCancellable>()
    
    init() {
        refresh()
        bind()
        getSchedule()
    }

    func refresh() {
        if let stopName = Settings.shared.stopLocation?.name {
            if !selectedStop.isEmpty, selectedStop != stopName {
                Settings.shared.trips = []
            }
            selectedStop = stopName
            isStopSelected = true
        } else {
            selectedStop = "Select stop"
            isStopSelected = false
        }
        
        savedTrips = Settings.shared.trips
    }
    
    func getSchedule() {
        guard
            fetchingScheduleTask == nil,
            let stopId = Settings.shared.stopLocation?.id
        else { return }
        
        fetchingScheduleTask = Task { @MainActor in
            let fetchedDepartures = await withTaskGroup(of: [Departure].self) { group -> [Departure] in
                for trip in savedTrips {
                    group.addTask {
                        do {
                            return try await NetworkManager.shared.getDepartures(
                                stopId: stopId,
                                directionId: trip.directionId,
                                lines: trip.line
                            )
                        } catch {
                            debugPrint(error)
                            return []
                        }
                    }
                }
                
                var collectedDepartures: [Departure] = []
                for await departures in group {
                    collectedDepartures.append(contentsOf: departures)
                }
                
                return collectedDepartures
            }
            
            scheduleItems = fetchedDepartures
                .sorted(using: SortDescriptor(\.rtTime))
                .map { ScheduleItem(
                    name: $0.name ?? "",
                    direction: $0.direction ?? "",
                    minutesTillDeparture: $0.rtTime ?? ""
                ) }
            
            
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
        
        $scheduleItems
            .sink { [weak self] items in
                debugPrint(items)
            }
            .store(in: &binding)
    }
}

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
    
    private lazy var serverDateTimeFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    private lazy var shortTimeFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
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
            let fetchedDepartures: [Departure]
            do {
                fetchedDepartures = try await NetworkManager.shared.getDepartures(
                    stopId: stopId,
                    departureLines: savedTrips.map { DepartureLine(id: $0.line, directionId: $0.directionId) }
                )
            } catch {
                fetchedDepartures = []
                debugPrint(error)
            }
    
            scheduleItems = fetchedDepartures
                .filter { $0.reachable == true }
                .sorted(using: SortDescriptor(\.rtTime))
                .map { [weak self] in ScheduleItem(
                    name: $0.name ?? "",
                    direction: $0.direction ?? "",
                    minutesTillDeparture: self?.getShortTimeAndMinutes(
                        date: $0.rtDate ?? $0.date,
                        time: $0.rtTime ?? $0.time
                    ) ?? ""
                ) }
        }
    }
    
    func setApiKey() {
        let newApiKey = newApiKeyText
        Settings.shared.apiKey = newApiKey
        self.apiKey = newApiKey
    }

    private func getShortTimeAndMinutes(date: String?, time: String?) -> String? {
        guard let date, let time, let date = serverDateTimeFormatter.date(from: "\(date) \(time)")
        else { return nil }
        
        let minutesLeft = Int((date.timeIntervalSinceNow/60).rounded(.up))
        let shortDate = shortTimeFormatter.string(from: date)
        return "\(shortDate) (\(minutesLeft) min)"
    }
    
    private func bind() {
        $isSelectingStop
            .merge(with: $isSelectingTrips)
            .filter { $0 == false }
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &binding)
    }
}

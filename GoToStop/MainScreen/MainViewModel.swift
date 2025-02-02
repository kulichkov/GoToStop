//
//  MainViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation
import GoToStopAPI
import Combine
import WidgetKit
import ActivityKit

struct TripInfo: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
}

struct ScheduleItem: Identifiable {
    let id = UUID()
    let name: String
    let direction: String
    let scheduledTime: Date?
    let realTime: Date?
    let isReachable: Bool
    let isCancelled: Bool
    var time: Date? { realTime ?? scheduledTime }
    var minutesLeft: UInt? {
        time
            .map { max(.zero, ceil($0.timeIntervalSince(.now) / 60.0)) }
            .map(UInt.init)
    }
    var timeDiffers: Bool {
        guard let realTime, let scheduledTime else { return false }
        return realTime != scheduledTime
    }
}

extension ScheduleItem {
    init?(_ departure: Departure) {
        self.init(
            name: departure.name,
            direction: departure.direction,
            scheduledTime: departure.scheduledTime,
            realTime: departure.realTime,
            isReachable: departure.isReachable,
            isCancelled: departure.isCancelled
        )
    }
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
    
    private var currentActivities: [Activity<GoToStopLiveActivityAttributes>] {
        Activity.activities
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

    private func refresh() {
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
        
        getSchedule()
        
        WidgetCenter.shared.reloadTimelines(ofKind: "kulichkov.GoToStop.GoToStopWidget")
    }
    
    func getSchedule() {
        guard
            fetchingScheduleTask == nil,
            let stopId = Settings.shared.stopLocation?.locationId
        else { return }
        
        fetchingScheduleTask = Task { @MainActor in
            let fetchedDepartures: [Departure]
            do {
                fetchedDepartures = try await NetworkManager.shared.getDepartures(
                    savedTrips.map { DepartureBoardRequest(stopId: stopId, lineId: $0.lineId, directionId: $0.directionId) }
                )
            } catch {
                fetchedDepartures = []
                debugPrint(error)
            }
    
            scheduleItems = fetchedDepartures
                .sorted(using: SortDescriptor(\.scheduledTime))
                .compactMap(ScheduleItem.init)
            
            updateLiveActivity()
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

extension MainViewModel {
    private func getLiveActivityContentState() -> GoToStopLiveActivityAttributes.ContentState {
        let trips: [GoToStopLiveActivityAttributes.TripItem] = scheduleItems.compactMap {
            guard let minutesLeft = ($0.realTime ?? $0.scheduledTime)
                .map({ max(.zero, ceil($0.timeIntervalSince(.now) / 60)) })
                .map(UInt.init)
            else { return nil }
            
            return .init(
                id: UUID().uuidString,
                name: $0.name,
                direction: $0.direction,
                minutesLeft: minutesLeft
            )
        }
        return GoToStopLiveActivityAttributes.ContentState(trips: trips)
    }
    
    func startLiveActivity() {
        guard
            ActivityAuthorizationInfo().areActivitiesEnabled,
            currentActivities.isEmpty
        else { return }
        
        let goToStopAttributes = GoToStopLiveActivityAttributes(stopName: selectedStop)
        let initialActivityState = getLiveActivityContentState()
        
        do {
            let newActivity = try Activity.request(
                attributes: goToStopAttributes,
                content: .init(state: initialActivityState, staleDate: nil)
            )
            debugPrint("Started activity: \(newActivity.id)")
        } catch {
            debugPrint("Couldn't start activity: \(String(describing: error))")
        }
    }
    
    func stopLiveActivity() {
        Task {
            for activity in currentActivities {
                debugPrint("Ending activity: \(activity.id)")
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
    
    func updateLiveActivity() {
        guard !currentActivities.isEmpty else { return }
        let contentState = getLiveActivityContentState()
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        Task {
            for activity in currentActivities {
                debugPrint("Updating activity: \(activity.id)")
                await activity.update(content)
            }
        }
    }
}

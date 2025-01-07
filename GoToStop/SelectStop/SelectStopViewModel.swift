//
//  SelectStopViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 22.12.24.
//

import Foundation
import Combine
import GoToStopAPI

struct StopLocationItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

final class SelectStopViewModel: ObservableObject {
    @Published private(set) var stopItems: [StopLocationItem] = []
    @Published private(set) var isSearching = false
    @Published var selectedItem: StopLocationItem?
    @Published var searchQuery: String = ""
    
    private var stopsFound: [UUID: StopLocation] = [:]
    private var searchTask: Task<Void, Never>?
    private var bindings = Set<AnyCancellable>()
    
    init() {
        bind()
        if let stopName = Settings.shared.stopLocation?.name {
            searchQuery = stopName
        }
    }
    
    private func bind() {
        $searchQuery
            .filter { $0.count > 2 }
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] searchQuery in
                self?.fetchStops(input: searchQuery)
            }
            .store(in: &bindings)
        
        $searchQuery
            .filter { $0.isEmpty }
            .sink { [weak self] _ in self?.clearSearch() }
            .store(in: &bindings)
        
        $selectedItem
            .compactMap(\.?.id)
            .compactMap { [weak self] in self?.stopsFound[$0] }
            .sink {
                debugPrint("Stop selected:", $0)
                Settings.shared.stopLocation = $0
            }
            .store(in: &bindings)
    }
    
    private func clearSearch() {
        isSearching = false
        searchTask?.cancel()
        searchTask = nil
        stopItems = []
        stopsFound = [:]
    }
    
    private func fetchStops(input: String) {
        isSearching = true
        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                var items: [StopLocationItem] = []
                var stops: [UUID: StopLocation] = [:]
                let stopsFetched = try await NetworkManager.shared.getStopLocations(input: input)
                debugPrint("Fetched stops:", stopsFetched.map(\.name))
                for stop in stopsFetched {
                    let item = StopLocationItem(name: stop.name)
                    stops[item.id] = stop
                    items.append(item)
                }
                
                stopItems = items
                stopsFound = stops
            } catch {
                debugPrint(error)
            }
            isSearching = false
        }
    }
    
}

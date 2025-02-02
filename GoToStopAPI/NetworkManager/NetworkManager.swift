//
//  NetworkManager.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import Foundation

public enum NetworkManagerError: Error {
    case wrongUrl
    case wrongRequest
}

final public class NetworkManager {
    public static let shared = NetworkManager()
    
    private let baseUrl: String = "https://www.rmv.de/hapi"
    
    private init() {}
    
    /// Can be used to perform a pattern matching of a user input and to retrieve
    /// a list of possible matches in the journey planner database. Possible matches might be stops/stations.
    /// - Parameter input: A search query.
    /// - Returns: The result is a list of possible matches (locations) where the user might pick one entry
    /// to ask for a departure board of this stop/station.
    public func getStopLocations(
        input: String
    ) async throws -> [StopLocation] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "input", value: input))
        queryItems.append(URLQueryItem(name: "type", value: "S"))
        queryItems.append(URLQueryItem(name: "withProducts", value: "0"))

        var urlComponents = URLComponents(string: baseUrl + "/location.name")
        urlComponents?.queryItems = queryItems
        let stopsAndCoordinates: LocationNameResponse = try await sendDataRequest(urlComponents)
        return stopsAndCoordinates.locations
            .compactMap { location in
                switch location {
                case .coordLocation: nil
                case let .stopLocation(response): StopLocation(response)
                }
            }
    }
    
    public func getStopLocations(
        inputs: [String]
    ) async throws -> [StopLocation] {
        try await withThrowingTaskGroup(of: [StopLocation].self) { [weak self] group -> [StopLocation] in
            for input in inputs {
                group.addTask {
                    try await self?.getStopLocations(input: input) ?? []
                }
            }
            
            var collectedStops: [StopLocation] = []
            for try await stops in group {
                collectedStops.append(contentsOf: stops)
            }
            
            return collectedStops
        }
    }
    
    /// The departure board can be retrieved by a call to the departureBoard service. This method will return the
    /// next departures (or less if not existing) from a given point in time within a duration covered time span.
    /// The default duration size is 60 minutes.
    ///
    /// - Parameters:
    ///   - stopId: Specifies the station/stop ID for which the departures shall be retrieved.
    ///   Required if extId is not present. Such ID can be retrieved from the location.name service.
    ///   - directionId: If only vehicles departing or arriving from a certain direction shall be returned,
    ///   specify the direction by giving the station/stop ID of the last stop on the journey.
    ///   - lines: Only journeys running the given line are part of the result.
    ///   To filter multiple lines, separate the codes by comma.
    ///   If the line should not be part of the be trip, negate it by putting ! in front of it.
    /// - Returns: The result list always contains all departures running the last minute found
    /// even if the requested maximum was overrun.
    public func getDepartures(
        _ request: DepartureBoardRequest
    ) async throws -> [Departure] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "id", value: request.stopId))
        
        if let directionId = request.directionId {
            queryItems.append(URLQueryItem(name: "direction", value: directionId))
        }
        if let lineId = request.lineId {
            queryItems.append(URLQueryItem(name: "lines", value: lineId))
        }
        if let date = request.date {
            queryItems.append(URLQueryItem(name: "date", value: date))
        }
        if let time = request.time {
            queryItems.append(URLQueryItem(name: "time", value: time))
        }
        if let duration = request.duration {
            queryItems.append(URLQueryItem(name: "duration", value: "\(duration)"))
        }

        var urlComponents = URLComponents(string: baseUrl + "/departureBoard")
        urlComponents?.queryItems = queryItems
        let departureBoard: DepartureBoardResponse = try await sendDataRequest(urlComponents)
        return departureBoard.departures.compactMap(Departure.init)
    }

    public func getDepartures(
        _ requests: [DepartureBoardRequest]
    ) async throws -> [Departure] {
        try await withThrowingTaskGroup(of: [Departure].self) { [weak self] group -> [Departure] in
            for request in requests {
                group.addTask {
                    try await self?.getDepartures(request) ?? []
                }
            }
            
            var collectedDepartures: [Departure] = []
            for try await departures in group {
                collectedDepartures.append(contentsOf: departures)
            }
            
            return collectedDepartures
        }
    }
}

private extension NetworkManager {
    
    func sendDataRequest<T: Decodable>(_ urlComponents: URLComponents?) async throws -> T {
        guard let url = urlComponents?.url else { throw NetworkManagerError.wrongUrl }
        var request = URLRequest(url: url)
        
        let apiKeyField = "Authorization"
        let apiKeyValue = "Bearer \(Settings.shared.apiKey ?? "")"

        let acceptField = "Accept"
        let acceptValue = "application/json"

        request.addValue(apiKeyValue, forHTTPHeaderField: apiKeyField)
        request.addValue(acceptValue, forHTTPHeaderField: acceptField)

        let (data, response) = try await URLSession.shared.data(for: request)
        debugPrint(response)
        debugPrint(String(data: data, encoding: .utf8) ?? "No Data")
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
}

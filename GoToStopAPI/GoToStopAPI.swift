//
//  GoToStopAPI.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation

public enum NetworkManagerError: Error {
    case wrongUrl
    case wrongRequest
}

final public class NetworkManager {
    public var apiKey: String?
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

        var urlComponents = URLComponents(string: baseUrl + "/location.name")
        urlComponents?.queryItems = queryItems
        let stopsAndCoordinates: LocationName = try await sendDataRequest(urlComponents)
        return stopsAndCoordinates.locations
            .compactMap { location in
                switch location {
                case .coordLocation: nil
                case let .stopLocation(stopLocation): stopLocation
                }
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
        stopId: String,
        directionId: String? = nil,
        lines: String? = nil
    ) async throws -> [Departure] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "id", value: stopId))
        if let directionId {
            queryItems.append(URLQueryItem(name: "direction", value: directionId))
        }
        if let lines {
            queryItems.append(URLQueryItem(name: "lines", value: lines))
        }

        var urlComponents = URLComponents(string: baseUrl + "/departureBoard")
        urlComponents?.queryItems = queryItems
        let departureBoard: DepartureBoard = try await sendDataRequest(urlComponents)
        return departureBoard.departures
    }

}

private extension NetworkManager {
    
    func sendDataRequest<T: Decodable>(_ urlComponents: URLComponents?) async throws -> T {
        guard let url = urlComponents?.url else { throw NetworkManagerError.wrongUrl }
        var request = URLRequest(url: url)
        
        let apiKeyField = "Authorization"
        let apiKeyValue = "Bearer \(apiKey ?? "")"

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

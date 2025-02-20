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
    case noApiBearer
}

final public class NetworkManager: NSObject {
    public static let shared = NetworkManager()
    
    public let apiBearer: String? = {
        let bearer = Bundle.main.infoDictionary?["API_BEARER"] as? String
        guard let bearer, !bearer.isEmpty else { return nil }
        return bearer
    }()
    
    public let backgroundUrlSessionIdentifier: String = "kulichkov.GoToStop.BackgroundSession"
    private lazy var foregroundUrlSession = URLSession.shared
    private lazy var backgroundUrlSession: URLSession = {
        URLSession(
            configuration: URLSessionConfiguration.background(
                withIdentifier: backgroundUrlSessionIdentifier
            ),
            delegate: self,
            delegateQueue: nil
        )
    }()
    
    private let baseUrl: String = "https://www.rmv.de/hapi"
    
    private override init() {}
    
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
        
        let urlRequest = try prepareUrlRequest(urlComponents)
        let stopsAndCoordinates: LocationNameResponse = try await getData(with: urlRequest)
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
        let urlComponents = prepareDepartureBoardUrlComponents(request)
        let urlRequest = try prepareUrlRequest(urlComponents)
        let departureBoard: DepartureBoardResponse = try await getData(with: urlRequest)
        return departureBoard.departures?.compactMap(Departure.init) ?? []
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
    
    public func requestDepartures(
        _ request: DepartureBoardRequest
    ) throws {
        let urlComponents = prepareDepartureBoardUrlComponents(request)
        let urlRequest = try prepareUrlRequest(urlComponents)
        try requestData(with: urlRequest)
    }
    
    private func prepareDepartureBoardUrlComponents(_ request: DepartureBoardRequest) -> URLComponents? {
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
        
        return urlComponents
    }
}

extension NetworkManager {
    private func prepareUrlRequest(_ urlComponents: URLComponents?) throws -> URLRequest {
        guard let apiBearer else { throw NetworkManagerError.noApiBearer }
        guard let url = urlComponents?.url else { throw NetworkManagerError.wrongUrl }
        
        var request = URLRequest(url: url)
                
        let apiKeyField = "Authorization"
        let apiKeyValue = "Bearer \(apiBearer)"

        let acceptField = "Accept"
        let acceptValue = "application/json"

        request.addValue(apiKeyValue, forHTTPHeaderField: apiKeyField)
        request.addValue(acceptValue, forHTTPHeaderField: acceptField)
        
        return request
    }
    
    private func getData<T: Decodable>(with request: URLRequest) async throws -> T {
        let (data, response) = try await foregroundUrlSession.data(for: request)
        logger?.info("Network response: \(response)")
        logger?.info("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func requestData(with request: URLRequest) throws {
        let task = backgroundUrlSession.dataTask(with: request)
        logger?.info("Background url request task created: \(request)")
        task.resume()
        logger?.info("Background task for url request \(request) started: \(task)")
    }
}

extension NetworkManager: URLSessionDataDelegate {
    private func getSavedResponse<T: Decodable>(for request: URLRequest) -> T? {
        guard let filename = request.hashString else { return nil }
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        
        do {
            return try fileManager.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
                .first { $0.deletingPathExtension().lastPathComponent == filename }
                .map { try Data(contentsOf: $0) }
                .map { try JSONDecoder().decode(T.self, from: $0) }
        } catch {
            logger?.error("Could not get response for request \(request): \(error)")
            return nil
        }
    }
    
    private func saveReceivedData(_ data: Data, for task: URLSessionTask) {
        do {
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let tempFile = temporaryDirectory.appendingPathComponent("\(task.taskIdentifier).tmp")
            
            if tempFile.fileExists {
                logger?.info("Appending data \(data) to file: \(tempFile)")
                let fileHandle = try FileHandle(forWritingTo: tempFile)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                logger?.info("Creating file: \(tempFile)")
                try data.write(to: tempFile)
            }
        } catch {
            logger?.error("Error writing file: \(error)")
        }
    }
    
    private func handleCompletedDataTask(_ task: URLSessionTask) {
        do {
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let tempFile = temporaryDirectory.appendingPathComponent("\(task.taskIdentifier).tmp")
            guard let jsonName = task.originalRequest?.hashString else {
                logger?.error("Could not get JSON name")
                return
            }
            let jsonFile = temporaryDirectory.appendingPathComponent("\(jsonName).\(task.taskIdentifier)")
            logger?.info("Renaming \(tempFile) to \(jsonFile)")
            try FileManager.default.moveItem(at: tempFile, to: jsonFile)
        } catch {
            logger?.error("Error handling completed data task \(task): \(error)")
        }
    }
    
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        logger?.info("Session \(session.configuration.identifier ?? "no identifier") created task: \(task)")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        logger?.info("Session \(session.configuration.identifier ?? "no identifier") received data: \(data)")
        saveReceivedData(data, for: dataTask)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        logger?.info("Session \(session.configuration.identifier ?? "no identifier") completed task: \(task), error: \(error)")
        handleCompletedDataTask(task)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        logger?.info("Session \(session.configuration.identifier ?? "no identifier") finished background events")
    }
}

private extension URLRequest {
    var hashString: String? {
        guard
            let url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems
        else {
            logger?.error("Failed to generate hash string for request: \(self)")
            return nil
        }
        let queryItemsString = queryItems
            .sorted(using: SortDescriptor(\.name))
            .map { $0.name + ($0.value ?? .empty) }
            .joined()
        
        return String((urlComponents.path + queryItemsString).sha256.prefix(16))
    }
}

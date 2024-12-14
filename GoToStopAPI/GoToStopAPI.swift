//
//  GoToStopAPI.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 08/12/2024.
//

import Foundation

final public class NetworkManager {
    public var apiKey: String?
    public static let shared = NetworkManager()
    
    private init() {}
    
    public func getDepartures() async throws -> [Departure] {
        try await requestDepartureBoard().departures
    }

    private func requestDepartureBoard() async throws -> DepartureBoard {
        let apiKeyField = "Authorization"
        let apiKeyValue = "Bearer \(apiKey ?? "")"

        let acceptField = "Accept"
        let acceptValue = "application/json"

        let idField = "id"
        let idValue = "A=1@O=Frankfurt (Main) Kuhwaldstraße@X=8640584@Y=50116885@U=80@L=3001974@"
        let idQueryItem = URLQueryItem(name: idField, value: idValue)

        let directionField = "direction"
        let directionValue = "A=1@O=Frankfurt (Main) Rebstockbad@X=8619415@Y=50113792@U=80@L=3001979@B=1@p=1733421541@"
        let directionQueryItem = URLQueryItem(name: directionField, value: directionValue)

        let productsField = "products"
        let productsValue = "32"
        let productsQueryItem = URLQueryItem(name: productsField, value: productsValue)

        var urlComponents = URLComponents(string: "https://www.rmv.de/hapi/departureBoard")
        urlComponents?.queryItems = [
            idQueryItem,
            directionQueryItem,
            productsQueryItem,
        ]

        var departureBoardRequest = URLRequest(url: (urlComponents?.url)!)
        departureBoardRequest.addValue(apiKeyValue, forHTTPHeaderField: apiKeyField)
        departureBoardRequest.addValue(acceptValue, forHTTPHeaderField: acceptField)

        let data = try await URLSession.shared.data(for: departureBoardRequest).0
        
        return try JSONDecoder().decode(DepartureBoard.self, from: data)
    }

}

//
//  Trip.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

public struct Trip: Codable {
    public let name: String
    public let direction: String
    public let category: TransportCategory
    public let lineId: String
    public let directionId: String
    
    public init(
        name: String,
        direction: String,
        category: TransportCategory,
        lineId: String,
        directionId: String
    ) {
        self.name = name
        self.direction = direction
        self.category = category
        self.lineId = lineId
        self.directionId = directionId
    }
}

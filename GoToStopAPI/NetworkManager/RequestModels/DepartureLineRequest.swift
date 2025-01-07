//
//  DepartureLineRequest.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 25.12.24.
//

public struct DepartureLineRequest {
    public let id: String
    public let directionId: String
    
    public init(
        id: String,
        directionId: String
    ) {
        self.id = id
        self.directionId = directionId
    }
}

//
//  Departure.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

public struct Departure {
    public let name: String
    public let stopId: String
    public let category: TransportCategory
    public let lineId: String
    public let scheduledTime: Date?
    public let realTime: Date?
    public let isCancelled: Bool
    public let isReachable: Bool
    public let direction: String
    public let directionId: String
}

extension Departure {
    init?(_ response: DepartureResponse) {
        guard
            let name = response.name,
            let product = response.product?.first,
            let stopId = response.stopid,
            let catOut = product.catOut,
            let lineId = product.line,
            let direction = response.direction,
            let directionId = response.directionId
        else { return nil }
        
        let category = TransportCategory(rawValue: catOut) ?? .unknown
        let scheduledTime = ServerDateFormatter.date(date: response.date, time: response.time)
        let realTime = ServerDateFormatter.date(date: response.rtDate, time: response.rtTime)
        let isCancelled = response.cancelled ?? false
        let isReachable = response.reachable ?? true
        
        self.init(
            name: name,
            stopId: stopId,
            category: category,
            lineId: lineId,
            scheduledTime: scheduledTime,
            realTime: realTime,
            isCancelled: isCancelled,
            isReachable: isReachable,
            direction: direction,
            directionId: directionId
        )
    }
}


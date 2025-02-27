//
//  Departure.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 06.01.25.
//

import Foundation

public struct Departure: Sendable {
    public let name: String
    public let stop: String
    public let stopId: String
    public let category: TransportCategory
    public let lineId: String
    public let scheduledTime: Date?
    public let realTime: Date?
    public let isCancelled: Bool
    public let isReachable: Bool
    public let direction: String
    public let directionId: String
    public let messages: [Message]
    
    public var time: Date? {
        realTime ?? scheduledTime
    }
}

public struct Message: Sendable {
    public let isActive: Bool
    public let header: String
    public let text: String
    public let urlDescription: String?
    public let url: URL?
}

extension Departure {
    init?(_ response: DepartureResponse) {
        guard
            let name = response.name,
            let product = response.product?.first,
            let stop = response.stop,
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
        let messages = response.getMessages()
        
        self.init(
            name: name,
            stop: stop,
            stopId: stopId,
            category: category,
            lineId: lineId,
            scheduledTime: scheduledTime,
            realTime: realTime,
            isCancelled: isCancelled,
            isReachable: isReachable,
            direction: direction,
            directionId: directionId,
            messages: messages
        )
    }
}

private extension DepartureResponse {
    func getMessages() -> [Message] {
        guard let messages = messages?.message else { return [] }
        return messages.map { messageInfo in
            let channel = messageInfo.channel?.first { !($0.url ?? []).isEmpty }
            let urlData = channel?.url?.first { !($0.url ?? "").isEmpty }
            let urlDescription = urlData?.name
            let url = urlData?.url.map(URL.init(string:)) ?? nil
            
            return Message(
                isActive: messageInfo.act ?? false,
                header: messageInfo.head ?? "",
                text: messageInfo.text ?? "",
                urlDescription: urlDescription,
                url: url
            )
        }
    }
}

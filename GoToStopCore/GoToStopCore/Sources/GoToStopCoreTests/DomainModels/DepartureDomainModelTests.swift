//
//  DepartureDomainModelTests.swift
//  GoToStopCore
//
//  Created by Mikhail Kulichkov on 08.03.25.
//

import Testing
import Foundation
@testable
import GoToStopCore

private extension Date {
    static let mock = Date(timeIntervalSince1970: 1741008060)
}

private extension ProductResponse {
    static let mock = ProductResponse(
        name: nil,
        internalName: nil,
        displayNumber: nil,
        num: nil,
        line: UUID().uuidString,
        lineId: nil,
        catOut: UUID().uuidString,
        catIn: nil,
        catCode: nil,
        cls: nil,
        catOutS: nil,
        catOutL: nil,
        operatorCode: nil,
        admin: nil,
        routeIdxFrom: nil,
        routeIdxTo: nil,
        matchId: nil
    )
}

private extension DepartureResponse {
    static func mock(
        product: [ProductResponse] = [.mock],
        messageResponse: MessagesResponse? = nil
    ) -> DepartureResponse {
        DepartureResponse(
            journeyDetailRef: .init(ref: "TO#3000529#"),
            product: product,
            name: UUID().uuidString,
            type: nil,
            stop: UUID().uuidString,
            stopid: UUID().uuidString,
            stopExtId: nil,
            lon: nil,
            lat: nil,
            prognosisType: nil,
            time: nil,
            date: nil,
            rtTime: "13:21:00",
            rtDate: "2025-03-03",
            reachable: nil,
            cancelled: nil,
            direction: UUID().uuidString,
            messages: messageResponse
        )
    }
}

@Suite("Departure tests", .tags(.domainModels))
struct DepartureDomainModelTests {
    
    struct TimeArgument {
        let scheduledTime: Date?
        let realTime: Date?
    }
    
    @Test(arguments: [
        TimeArgument(scheduledTime: .mock, realTime: .mock),
        TimeArgument(scheduledTime: .mock, realTime: nil),
        TimeArgument(scheduledTime: nil, realTime: .mock),
        TimeArgument(scheduledTime: nil, realTime: nil),
    ])
    func departureInit(_ time: TimeArgument) {
        let departure = Departure(
            name: UUID().uuidString,
            stop: UUID().uuidString,
            stopId: UUID().uuidString,
            category: .unknown,
            lineId: UUID().uuidString,
            scheduledTime: time.scheduledTime,
            realTime: time.realTime,
            isCancelled: false,
            isReachable: true,
            direction: UUID().uuidString,
            directionId: UUID().uuidString,
            messages: []
        )
        
        if time.realTime == nil, time.scheduledTime == nil {
            #expect(departure.time == nil)
        } else {
            #expect(departure.time == .mock)
        }
    }
    
    @Test
    func departureInitFromResponse() throws {
        let departureResponse = DepartureResponse.mock(
            messageResponse: .init(message: [.init(
                id: nil,
                channel: [.init(
                    name: nil,
                    url: [.init(
                        name: "Some channel name",
                        url: "https://some-channel-url.com"
                    )],
                    validFromTime: nil,
                    validFromDate: nil,
                    validToTime: nil,
                    validToDate: nil
                )],
                act: true,
                head: "Mocked message head",
                lead: nil,
                text: "Mocked message text"
            )])
        )
        let departure = try #require(Departure(departureResponse))
        
        let currentZoneGMTOffset = TimeInterval(TimeZone.current.secondsFromGMT())
        let realTime = Date.mock.addingTimeInterval(-currentZoneGMTOffset)
        
        #expect(departure.name == departureResponse.name)
        #expect(departure.stop == departureResponse.stop)
        #expect(departure.stopId == departureResponse.stopid)
        #expect(departure.category == .unknown)
        #expect(departure.lineId == departureResponse.product?.first?.line)
        #expect(departure.scheduledTime == nil)
        #expect(departure.realTime == realTime)
        #expect(departure.isCancelled == false)
        #expect(departure.isReachable == true)
        #expect(departure.direction == departureResponse.direction)
        #expect(departure.directionId == departureResponse.directionId)
        
        let message = try #require(departure.messages.first)
        #expect(message.isActive == true)
        #expect(message.header == "Mocked message head")
        #expect(message.text == "Mocked message text")
        #expect(message.urlDescription == "Some channel name")
        #expect(message.url == URL(string: "https://some-channel-url.com"))
    }
    
    @Test
    func departureInitFromResponseNil() {
        let departureResponse = DepartureResponse.mock(product: [])
        let departure = Departure(departureResponse)
        
        #expect(departure == nil)
    }

    @Test
    func departureInitFromResponseNoMessages() throws {
        let departureResponse = DepartureResponse.mock()
        let departure = try #require(Departure(departureResponse))
        
        #expect(departure.messages.isEmpty)
    }
    
    @Test
    func departureInitFromResponseDefaultMessageValues() throws {
        let departureResponse = DepartureResponse.mock(
            messageResponse: .init(message: [.init(
                id: nil,
                channel: [.init(
                    name: nil,
                    url: [.init(
                        name: nil,
                        url: nil
                    )],
                    validFromTime: nil,
                    validFromDate: nil,
                    validToTime: nil,
                    validToDate: nil
                )],
                act: nil,
                head: nil,
                lead: nil,
                text: nil
            )])
        )
        
        let departure = try #require(Departure(departureResponse))
        let message = try #require(departure.messages.first)
        #expect(message.isActive == false)
        #expect(message.header.isEmpty)
        #expect(message.text.isEmpty)
        #expect(message.urlDescription == nil)
        #expect(message.url == nil)
    }
    
    @Test
    func departureInitFromResponseMessageValuesNoUrl() throws {
        let departureResponse = DepartureResponse.mock(
            messageResponse: .init(message: [.init(
                id: nil,
                channel: [.init(
                    name: nil,
                    url: nil,
                    validFromTime: nil,
                    validFromDate: nil,
                    validToTime: nil,
                    validToDate: nil
                )],
                act: nil,
                head: nil,
                lead: nil,
                text: nil
            )])
        )
        
        let departure = try #require(Departure(departureResponse))
        let message = try #require(departure.messages.first)
        #expect(message.isActive == false)
        #expect(message.header.isEmpty)
        #expect(message.text.isEmpty)
        #expect(message.urlDescription == nil)
        #expect(message.url == nil)
    }
    
}

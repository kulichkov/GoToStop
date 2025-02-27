//
//  DepartureBoardRequest.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 02.02.25.
//

public struct DepartureBoardRequest: Sendable {
    public let stopId: String
    
    public let lineId: String?
    
    public let directionId: String?
    
    /// Sets the start date for which the
    /// departures shall be retrieved.
    /// Represented in the format YYYY-MM-DD.
    /// By default the current server date is used
    public let date: String?
    
    /// Sets the start time for which the
    /// departures shall be retrieved.
    /// Represented in the format hh:mm[:ss] in
    /// 24h nomenclature. Seconds will be
    /// ignored for requests.
    /// By default the current server time is used
    public let time: String?
    
    /// Period of departures in minutes (1-1439).
    /// Default is 60
    public let duration: Int?
    
    /// Maximum number of journeys to be returned. If no value is defined or -1, all
    /// departing/arriving services within the duration sized period are returned.
    /// Please note: maxJourneys is not a hard limit. If the limit of maxJourneys is
    /// reached and there are additional journeys that have the same
    /// departure/arrival time as the last journey within the limit (e.g. 14:57), those
    /// additional journeys are also returned. This ensures that scrolling forward works
    /// by executing another departure/arrival board request where the time is equal to
    /// the departure/arrival time of the last journey increased by one minute (14:58
    /// in our example).
    public let maxJourneys: Int?
    
    public init(
        stopId: String,
        lineId: String? = nil,
        directionId: String? = nil,
        date: String? = nil,
        time: String? = nil,
        duration: Int? = nil,
        maxJourneys: Int? = nil
    ) {
        self.stopId = stopId
        self.lineId = lineId
        self.directionId = directionId
        self.date = date
        self.time = time
        self.duration = duration
        self.maxJourneys = maxJourneys
    }
}

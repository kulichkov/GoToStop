//
//  TransportCategory.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 20.01.25.
//

public enum TransportCategory: String, Codable, Equatable, Sendable {
    case bus = "Bus"
    case ice = "ICE"
    case s = "S"
    case tram = "Tram"
    case u = "U-Bahn"
    case rb = "RB"
    case re = "RE"
    case ec = "EC"
    case unknown
}

extension TransportCategory: Comparable {
    public static func < (lhs: TransportCategory, rhs: TransportCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension TransportCategory {
    public var emoji: String {
        switch self {
        case .bus:
            "🚍"
        case .tram:
            "🚊"
        case .u:
            "🚇"
        case .s, .ice, .rb, .re, .ec:
            "🚆"
        case .unknown:
            "🚏"
        }
    }
}

//
//  GoToStopIntent.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 10.01.25.
//

import AppIntents
import Foundation

struct RefreshIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh"
        
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct GoToStopIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select trips parameters"
    static let description = IntentDescription("Selects parameters to display trips")
    
    @Parameter(title: "Stop")
    var stopLocation: StopLocation?
    
    @Parameter(title: "Trips")
    var trips: [Trip]?
}

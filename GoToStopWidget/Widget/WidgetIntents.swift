//
//  GoToStopIntent.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 10.01.25.
//

import AppIntents
import Foundation

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
        
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct GoToStopIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select trips parameters"
    static var description = IntentDescription("Selects parameters to display trips")
    
    @Parameter(title: "Stop")
    var stopLocation: StopLocation?
    
    @Parameter(title: "Trips")
    var trips: [Trip]?
}

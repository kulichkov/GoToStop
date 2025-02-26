//
//  GoToStopIntent.swift
//  GoToStopWidgetExtension
//
//  Created by Mikhail Kulichkov on 10.01.25.
//

import AppIntents
import Foundation

struct GoToStopIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select trips parameters"
    static var description = IntentDescription("Selects parameters to display trips")
    
    @Parameter(title: "Stop")
    var stopLocation: StopLocation?
    
    @Parameter(title: "Trips", size: 3)
    var trips: [Trip]?
}

struct RefreshIntent: AppIntent {
    @Parameter(title: "WidgetHash")
    var widgetHash: String?
    
    static var title: LocalizedStringResource = "Refresh"
        
    func perform() async throws -> some IntentResult {
        logger?.debug("=====\(String(describing: widgetHash))")
        return .result()
    }
}

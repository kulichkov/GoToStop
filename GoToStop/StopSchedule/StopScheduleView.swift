//
//  StopScheduleView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 26.01.25.
//

import SwiftUI

struct StopScheduleView: View {
    @StateObject var viewModel: StopScheduleViewModel
    
    var body: some View {
        List {
            Section("Selected Stop") {
                Text(viewModel.stop.name)
            }
            Section("Selected Trips") {
                ForEach(viewModel.trips) { tripItem in
                    VStack(alignment: .leading) {
                        Text(tripItem.trip.name)
                        Text(tripItem.trip.direction)
                    }
                }
            }
            Section("Schedule as of " + Date.now.formatted(date: .omitted, time: .shortened)) {
                ForEach(viewModel.scheduleItems) { scheduleItem in
                    VStack(alignment: .leading) {
                        Text(scheduleItem.name)
                        Text(scheduleItem.direction)
                        HStack {
                            if let realTime = scheduleItem.realTime {
                                Text("Actual: " + realTime.formatted(date: .omitted, time: .shortened))
                            }
                            if let scheduledTime = scheduleItem.scheduledTime {
                                Text("Scheduled: " + scheduledTime.formatted(date: .omitted, time: .shortened))
                            }
                        }
                    }
                }
            }
        }
        .onOpenURL(perform: viewModel.handleWidgetURL)
    }
}

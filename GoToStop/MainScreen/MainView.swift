//
//  MainView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 50)
                Button(viewModel.selectedStop) { viewModel.isSelectingStop = true }
                Spacer().frame(height: 16)
                Text(viewModel.selectedTrips.isEmpty ? "No selected trips:" : "Selected trips:")
                Spacer().frame(height: 16)
                ForEach(viewModel.selectedTrips) { trip in
                    HStack {
                        Text(trip.name)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 16)
                        Text(trip.direction)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.caption)
                }
                
                Spacer().frame(height: 16)
                Button("Select trips") { viewModel.isSelectingTrips = true }
                    .disabled(!viewModel.isStopSelected)
                
                Text("Live Activity:")
                HStack {
                    Button("Start") { viewModel.startLiveActivity() }
                    Spacer().frame(width: 50)
                    Button("Stop") { viewModel.stopLiveActivity() }
                }
                
                Spacer().frame(height: 32)
                HStack {
                    Text("Departure board:")
                    Spacer()
                    Button("Refresh") { viewModel.getSchedule() }
                }
                ForEach(viewModel.scheduleItems) { departure in
                    HStack {
                        Text(departure.name)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 16)
                        Text(departure.direction)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 16)
                        if let departureTime = departure.realTime ?? departure.scheduledTime {
                            Text(departureTime.formatted(date: .omitted, time: .shortened))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .font(.caption)
                }
                
                Spacer(minLength: 100)
                TextField(
                    viewModel.apiKey ?? "Enter RMV API key",
                    text: $viewModel.newApiKeyText
                )
                Button("Set API key") { viewModel.setApiKey() }
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        .sheet(
            isPresented: $viewModel.isSelectingStop,
            onDismiss: { viewModel.isSelectingStop = false }
        ) {
            SelectStopView(viewModel: SelectStopViewModel(), isPresented: $viewModel.isSelectingStop)
        }
        .sheet(
            isPresented: $viewModel.isSelectingTrips,
            onDismiss: { viewModel.isSelectingTrips = false }
        ) {
            SelectTripsView(viewModel: SelectTripsViewModel(), isPresented: $viewModel.isSelectingTrips)
        }
    }
}

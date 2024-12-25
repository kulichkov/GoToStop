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
        VStack {
            Spacer().frame(height: 50)
            Button(viewModel.selectedStop) { viewModel.isSelectingStop = true }
            Spacer().frame(height: 50)
            Button("Select trips") { viewModel.isSelectingTrips = true }
                .disabled(!viewModel.isStopSelected)
            
            Spacer(minLength: 16)
            TextField(
                viewModel.apiKey ?? "Enter RMV API key",
                text: $viewModel.newApiKeyText
            )
            Button("Set API key") { viewModel.setApiKey() }
        }
        .multilineTextAlignment(.center)
        .padding()
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

//#Preview {
//    MainView()
//}

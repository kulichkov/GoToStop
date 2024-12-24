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
            
            if let testSucceeded = viewModel.testSucceeded {
                Circle()
                    .fill(testSucceeded ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
            }
            Spacer().frame(height: 50)
            Button(viewModel.selectedStop) { viewModel.isSelectingStop = true }
            Spacer().frame(height: 150)
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
    }
}

//#Preview {
//    MainView()
//}

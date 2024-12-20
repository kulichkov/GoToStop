//
//  MainView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import SwiftUI

struct MainView: View {
    @StateObject
    var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            
            if let testSucceeded = viewModel.testSucceeded {
                Circle()
                    .fill(testSucceeded ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
            }
            Spacer().frame(height: 50)
            Button("Get stops") { viewModel.getStops() }
            Spacer().frame(height: 150)
            TextField(
                viewModel.apiKey ?? "Enter RMV API key",
                text: $viewModel.newApiKeyText
            )
            Button("Set API key") {  }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    MainView()
}

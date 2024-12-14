//
//  ContentView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 14.12.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MainViewModel()
    @State private var text: String = ""
    var apiKeyInfo: String {
        if
            let apiKey = viewModel.apiKey,
            !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            "Current API key:\n\(apiKey)"
        } else {
            "No API key"
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(apiKeyInfo)
            if let testSucceeded = viewModel.testSucceeded {
                Circle()
                    .fill(testSucceeded ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
            }
            Spacer().frame(height: 50)
            Button("Get departures") { viewModel.getDepartures() }
            Spacer().frame(height: 150)
            TextField("Enter RMV API key", text: $text)
            Button("Set API key") { viewModel.setApiKey(text) }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    ContentView()
}

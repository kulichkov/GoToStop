//
//  WelcomeView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 01.02.25.
//

import SwiftUI

struct WelcomeView: View {
    @State var goToDebugMenu: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Welcome to GoToStop")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .onTapGesture(count: 7) {
                        logger?.info("Go to debug menu")
                        goToDebugMenu = true
                    }
                
                Text("Enhance your experience by adding GoToStop widget")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 16) {
                        Image(systemName: "rectangle.stack.fill.badge.plus")
                            .foregroundColor(.accentColor)
                        Text("Add GoToStop widget to your Home Screen")
                            .font(.body)
                    }
                    
                    HStack(spacing: 16) {
                        Image(systemName: "wrench.fill")
                            .foregroundColor(.accentColor)
                        Text("Setup your widget in Edit Widget")
                            .font(.body)
                    }
                    
                    HStack(spacing: 16) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.accentColor)
                        Text("Stay updated, right from your home screen")
                            .font(.body)
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(32)
            .padding(.horizontal, 20)
        }
        .navigationDestination(isPresented: $goToDebugMenu) {
            if #available(iOS 18.0, *) {
                DebugMenuView(viewModel: DebugMenuViewModel())
            } else {
                Text("iOS 18.0 or later is required for debugging")
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

//
//  WelcomeView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 01.02.25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to GoToStop")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
            
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
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

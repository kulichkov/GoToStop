//
//  SelectTripsView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 24.12.24.
//

import SwiftUI
import Combine

struct SelectTripsView: View {
    @StateObject var viewModel: SelectTripsViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(viewModel.tripItems) { item in
                HStack {
                    Text(
                        [
                            item.trip.category.emoji,
                            item.trip.name,
                            "\n→",
                            item.trip.direction
                        ]
                            .joined(separator: " ")
                    )
                }
                .foregroundColor(viewModel.selectedItems.contains(item) ? .blue : .primary)
                .listRowBackground(viewModel.selectedItems.contains(item) ? Color.blue.opacity(0.2) : nil)
                .contentShape(.rect)
                .onTapGesture { viewModel.handleTripTap(item) }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select trips")
            .toolbar { Button("Done") {
                viewModel.processSelectedTrips()
                isPresented = false
            } }
        }
    }
}

//#Preview {
//    SelectStopView(viewModel: .init(
//        stopsFound: [],
//        isSearching: false
//    ))
//}


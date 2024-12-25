//
//  SelectStopView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import SwiftUI
import Combine

struct SelectStopView: View {
    @StateObject var viewModel: SelectStopViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a stop...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .overlay {
                        if !viewModel.searchQuery.isEmpty {
                            HStack {
                                Spacer()
                                Button(action: {
                                    viewModel.searchQuery = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                    .padding()
                
                List(viewModel.stopItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                    }
                    .foregroundColor(viewModel.selectedItem == item ? .blue : .primary)
                    .listRowBackground(viewModel.selectedItem == item ? Color.blue.opacity(0.2) : nil)
                    .contentShape(.rect)
                    .onTapGesture { viewModel.selectedItem = item }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Select stop")
            .toolbar { Button("Done") { isPresented = false }
            }
        }
    }
}

//#Preview {
//    SelectStopView(viewModel: .init(
//        stopsFound: [],
//        isSearching: false
//    ))
//}


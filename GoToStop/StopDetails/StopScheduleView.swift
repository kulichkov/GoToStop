//
//  StopScheduleView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 01.02.25.
//

import SwiftUI

struct StopScheduleView: View {
    @StateObject var viewModel: StopScheduleViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Station Name
                    Text(viewModel.stop.name)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // Transport List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tracking transport")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(viewModel.trips) { tripItem in
                            HStack(alignment: .top) {
                                Text("\(tripItem.trip.name) → \(tripItem.trip.direction)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    // Schedule List
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Schedule on \(Date.now.formatted(date: .abbreviated, time: .shortened))")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        if viewModel.scheduleItems.isEmpty {
                            HStack {
                                Text("Loading...")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.scheduleItems, content: makeScheduleItemView)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }
        .navigationTitle("Stop schedule")
        .onOpenURL(perform: viewModel.handleWidgetURL)
    }
    
    func makeScheduleItemView(_ item: ScheduleItem) -> some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(item.name)")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("→ \(item.direction)")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading) {
                        if let minutesUntilDeparture = item.minutesLeft {
                            Text("Departs in \(minutesUntilDeparture)")
                                .font(.footnote)
                                .foregroundColor(.green)
                                .brightness(-0.2)
                        }
                        
                        if let scheduledTime = item.scheduledTime {
                            Text("Scheduled at \(scheduledTime.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        if item.timeDiffers, let actualTime = item.realTime {
                            Text("Actually at \(actualTime.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                                .foregroundColor(item.isCancelled ? .gray : .orange)
                                .brightness(item.isCancelled ? 1.0 : -0.2)
                        }
                    }
                    .strikethrough(item.isCancelled)
                    
                    if item.isCancelled {
                        Text("Cancelled")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    
                    ForEach(item.activeMessages.indices, id: \.self) { index in
                        Text("⚠️ \(item.activeMessages[index].header)")
                            .font(.footnote)
                            .foregroundColor(.primary)
                        
                        if let url = item.activeMessages[index].url {
                            Button(action: { UIApplication.shared.open(url) }) {
                                Text("\(item.activeMessages[index].urlDescription ?? "Details")")
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
        }
}

//
//  DebugMenuView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 09.02.25.
//

import SwiftUI
import GoToStopAPI

@available(iOS 18.0, *)
struct DebugMenuView: View {
    @StateObject var viewModel: DebugMenuViewModel
    
    var body: some View {
        VStack {
            if let url = viewModel.logsLink {
                ShareLink(
                    item: url
                ) {
                    Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark.fill")
                    Text("Share logs")
                }
            } else {
                Button(action: viewModel.startMakingLogs) { Text("Start creating logs") }
                Spacer().frame(height: 32)
                Button(action: viewModel.stopMakingLogs) { Text("Stop creating logs") }
            }
        }
            .navigationBarTitle("Debug Menu")
    }
}

@available(iOS 18.0, *)
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView(viewModel: DebugMenuViewModel())
    }
}


//
//  DebugMenuView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 09.02.25.
//

import SwiftUI

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
                Text("Logs are being collected...")
                    .onAppear(perform: viewModel.prepareLogs)
            }
        }
            .onDisappear(perform: viewModel.removeLogs)
            .navigationBarTitle("Debug Menu")
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView(viewModel: DebugMenuViewModel())
    }
}


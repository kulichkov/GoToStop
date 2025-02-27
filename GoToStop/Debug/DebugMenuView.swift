//
//  DebugMenuView.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 09.02.25.
//

import SwiftUI

@available(iOS 18.0, *)
struct DebugMenuView: View {
    @StateObject var viewModel: DebugMenuViewModel
    
    var body: some View {
        VStack {
            if let url = viewModel.zipFileUrl {
                ShareLink(
                    item: url
                ) {
                    Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark.fill")
                    Text("Share logs")
                }
            } else if let error = viewModel.error {
                Text(error)
            } else {
                Text("Collecting logs...")
            }
        }
        .onAppear(perform: viewModel.startCollectingWidgetLogs)
        .navigationBarTitle("Debug Menu")
    }
}

@available(iOS 18.0, *)
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView(viewModel: DebugMenuViewModel())
    }
}


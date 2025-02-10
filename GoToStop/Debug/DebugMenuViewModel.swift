//
//  DebugMenuViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 09.02.25.
//

import Foundation

final class DebugMenuViewModel: ObservableObject {
    @Published var logsLink: URL? = nil
    
    func prepareLogs() {
        logger?.info("Prepare logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.logsLink = URL(string: "file://Users/kulichkov/Library/Developer/CoreSimulator/Devices/ADFE2C3E-9A3D-4FA6-A037-6281B3F724A7/data/Documents/EEB7310E-E8DD-48FC-B2A2-5E6C815F2FF9.zip")
        }
        let fileExists = FileManager.default.fileExists(atPath: "/Users/kulichkov/Library/Developer/CoreSimulator/Devices/ADFE2C3E-9A3D-4FA6-A037-6281B3F724A7/data/Documents/EEB7310E-E8DD-48FC-B2A2-5E6C815F2FF9.zip")
        logger?.notice("File exists: \(fileExists)")
    }
    
    func removeLogs() {
        logger?.info("Remove logs")
    }
}


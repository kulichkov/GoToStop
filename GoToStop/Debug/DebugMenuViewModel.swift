//
//  DebugMenuViewModel.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 09.02.25.
//

import Foundation
import GoToStopAPI
import WidgetKit

@available(iOS 18.0, *)
final class DebugMenuViewModel: ObservableObject {
    @Published var logsLink: URL? = nil
    
    private let loggerExporter = LogExporter()
    private var zipFileUrl: URL?
    
    func startMakingLogs() {
        cleanUp()
        Settings.shared.isSharingLogs = true
        logger?.info("Settings.shared.isSharingLogs set to \(Settings.shared.isSharingLogs)")
        logger?.info("Log urls: \(Settings.shared.logsUrls)")
        logger?.info("Log errors: \(Settings.shared.logsErrors)")
        
        
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .current,
            using: { [weak self] _ in self?.handleSettingsChange() }
        )
        
        WidgetCenter.shared.reloadAllTimelines()
        
//        makeAppLogs()
        
//        cleanUp()
//        Settings.shared.isSharingLogs = false
    }
    
    func stopMakingLogs() {
        NotificationCenter.default.removeObserver(self)
        
        logger?.info("Settings.shared.isSharingLogs WAS set to \(Settings.shared.isSharingLogs)")
        logger?.info("Log urls: \(Settings.shared.logsUrls)")
        logger?.info("Log errors: \(Settings.shared.logsErrors)")
        Settings.shared.isSharingLogs = false
        logger?.info("Settings.shared.isSharingLogs set to \(Settings.shared.isSharingLogs)")
        cleanUp()
    }
    
    private func makeAppLogs() {
        logger?.info("Make app logs")
        let name = "\(ProcessInfo().processName)_pid\(ProcessInfo().processIdentifier)"
        do {
            let appLogsUrl = try loggerExporter.makeJson(name: name)
            Settings.shared.logsUrls.append(appLogsUrl)
        } catch {
            Settings.shared.logsErrors.append(error.localizedDescription)
            logger?.error("Failed to prepare logs: \(error)")
        }
    }
    
    private func cleanUp() {
        logger?.info("Remove log-related files")
        for url in Settings.shared.logsUrls {
            do {
                logger?.error("Delete log at \(url)")
                try FileManager.default.removeItem(at: url)
            } catch {
                logger?.error("Failed to delete log at \(url): \(error)")
            }
        }
        Settings.shared.logsUrls = []
        Settings.shared.logsErrors = []
    }
    
    private func handleSettingsChange() {
        Task {
            do {
                let numberOfWidgets = try await WidgetCenter.shared.currentConfigurations().count
                let numberOfWidgetLogs = Settings.shared.logsUrls.count
                let numberOfWidgetLogErrors = Settings.shared.logsErrors.count
                
                if numberOfWidgetLogs + numberOfWidgetLogErrors == numberOfWidgets {
                    logger?.info("Widget logs are ready.")
                    // TODO: get the app logs and share logs. Then clean everything up.
                } else {
                    logger?.info("\(numberOfWidgets) log(s) are expected. But found \(numberOfWidgetLogs) log(s) and \(numberOfWidgetLogErrors) error(s).")
                    logger?.info("Log urls: \(Settings.shared.logsUrls)")
                    logger?.info("Log errors: \(Settings.shared.logsErrors)")
                }
            } catch {
                logger?.error("Failed to get number of widgets: \(error)")
            }
        }
    }
}


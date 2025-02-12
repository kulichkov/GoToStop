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
    @Published var zipFileUrl: URL? = nil
    @Published var error: String? = nil
    
    private var timer: Timer?
    private var appLogsUrl: URL?
    private var widgetLogsUrl: URL? {
        get { Settings.shared.widgetLogsUrl }
        set { Settings.shared.widgetLogsUrl = newValue }
    }
    private var shouldCollectWidgetLogs: Bool {
        get { Settings.shared.shouldCollectWidgetLogs }
        set { Settings.shared.shouldCollectWidgetLogs = newValue }
    }
    
    private var logsUrls: [URL] {
        [
            appLogsUrl,
            widgetLogsUrl
        ]
            .compactMap { $0 }
    }
    private let logExporter = LogExporter()
    
    func startCollectingWidgetLogs() {
        logger?.info("Start collecting logs")
        cleanUpLogs()
        shouldCollectWidgetLogs = true
        WidgetCenter.shared.reloadAllTimelines()
        Task { await checkIfWidgetExists() }
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { [weak self] _ in self?.checkWidgetLogs() }
        )
    }
    
    private func checkIfWidgetExists() async {
        do {
            let widgets = try await WidgetCenter.shared.currentConfigurations()
            if widgets.isEmpty {
                logger?.info("No widget found. Stopping widget log collection...")
                shouldCollectWidgetLogs = false
            }
        } catch {
            logger?.error("Couldn't get any widget configuration: \(error)")
        }
    }
    
    private func checkWidgetLogs() {
        logger?.info("shouldCollectWidgetLogs set to \(self.shouldCollectWidgetLogs)")
        logger?.info("Widget log url: \(String(describing: self.widgetLogsUrl))")
        
        if !shouldCollectWidgetLogs {
            timer?.invalidate()
            timer = nil
            makeAppLogs()
            makeZipArchive()
        }
    }
    
    private func makeZipArchive() {
        guard !logsUrls.isEmpty else {
            logger?.error("No logs to compress!")
            error = "No logs found!"
            return
        }
        
        do {
            zipFileUrl = try logExporter.makeZip(name: "GoToStopLogs", from: logsUrls)
        } catch {
            logger?.error("Failed to make zip from logs: \(error)")
            self.error = "Failed to compress logs: \(error)"
            return
        }
    }
    
    private func makeAppLogs() {
        do {
            appLogsUrl = try logExporter.makeJson(name: "GoToStopAppLogs")
            logger?.info("The app logs url: \(String(describing: self.appLogsUrl))")
        } catch {
            logger?.error("Failed to prepare the app logs: \(error)")
        }
    }
    
    private func cleanUpLogs() {
        logger?.info("Remove log-related files")
        for url in logsUrls {
            do {
                logger?.error("Delete log at \(url)")
                try FileManager.default.removeItem(at: url)
            } catch {
                logger?.error("Failed to delete log at \(url): \(error)")
            }
        }
        widgetLogsUrl = nil
        appLogsUrl = nil
    }
    
}


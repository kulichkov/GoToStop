//
//  BackgroundSessionManager.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 22.02.25.
//

import Foundation
import Combine
import WidgetKit

final class BackgroundSessionManager: NSObject {
    public var backgroundSessionCompletion: (() -> Void)?
    public let backgroundUrlSessionIdentifier: String = "kulichkov.GoToStop.BackgroundSession"
    private lazy var backgroundUrlSession: URLSession = {
        let configuration = URLSessionConfiguration.background(
            withIdentifier: backgroundUrlSessionIdentifier
        )
        
        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
    }()
    private var bindings = Set<AnyCancellable>()
    private let requestFinishedSubject = PassthroughSubject<URLRequest, Never>()
    public var requestFinished: AnyPublisher<URLRequest, Never> {
        requestFinishedSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        
        requestFinished
            .throttle(for: .seconds(2), scheduler: RunLoop.main, latest: true)
            .sink { _ in
                if !Settings.shared.activeWidgetRequests.isEmpty {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            .store(in: &bindings)
    }
    
    func downloadData(with request: URLRequest) throws {
        Task {
            let urlRequests = await backgroundUrlSession.allTasks.compactMap(\.originalRequest)
            let runningRequest = urlRequests.first { $0.hashString == request.hashString }
            if let runningRequest {
                logger?.debug("Request \(runningRequest) is already running")
            } else {
                let task = backgroundUrlSession.downloadTask(with: request)
                task.resume()
                logger?.info("Background task for url request \(request) started: \(task)")
            }
        }
    }
    
    func getRunningRequests(_ requests: [URLRequest]) async -> [URLRequest] {
        await backgroundUrlSession.allTasks
            .compactMap(\.originalRequest)
            .filter(requests.contains)
    }

    private func saveCacheFile(from tempFile: URL, of task: URLSessionTask) {
        guard let urlRequestHashString = task.originalRequest?.hashString else {
            logger?.error("Could not get JSON name")
            return
        }
    
        do {
            try CacheFileManager.shared.saveCacheFile(named: urlRequestHashString, from: tempFile)
        } catch {
            logger?.error("Error handling completed data task \(task): \(error)")
        }
    }
}

extension BackgroundSessionManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        logger?.debug("Session download task \(downloadTask) finished downloading to location: \(location)")
        saveCacheFile(from: location, of: downloadTask)
        if let urlRequest = downloadTask.originalRequest {
            requestFinishedSubject.send(urlRequest)
        } else {
            logger?.warning("No original request for download task: \(downloadTask)")
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        logger?.info("Background session finished events")
        backgroundSessionCompletion?()
    }
}

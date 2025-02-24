//
//  BackgroundSessionManager.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 22.02.25.
//

import Foundation
import Combine

enum BackgroundSessionManagerError: Error {
    case noRequestHashString(URLRequest)
}

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
    
    func downloadData(with request: URLRequest) throws {
        let task = backgroundUrlSession.downloadTask(with: request)
        task.resume()
        logger?.info("Background task for url request \(request) started: \(task)")
    }

    private func saveCacheFile(from tempFile: URL, of task: URLSessionTask) {
        guard let urlRequestHashString = task.originalRequest?.hashString else {
            logger?.error("Could not get JSON name")
            return
        }
    
        do {
            logger?.info("Renaming \(tempFile) to \(urlRequestHashString)")
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
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        logger?.info("Background session finished events")
        backgroundSessionCompletion?()
    }
}

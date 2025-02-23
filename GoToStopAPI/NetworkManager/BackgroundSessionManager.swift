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
    public let requestFinished = PassthroughSubject<String, Never>()
    public let backgroundUrlSessionIdentifier: String = "kulichkov.GoToStop.BackgroundSession"
    private lazy var backgroundUrlSession: URLSession = {
        URLSession(
            configuration: URLSessionConfiguration.background(
                withIdentifier: backgroundUrlSessionIdentifier
            ),
            delegate: self,
            delegateQueue: nil
        )
    }()
    
    func downloadData(with request: URLRequest) throws {
        let task = backgroundUrlSession.downloadTask(with: request)
        logger?.info("Background url request task created: \(request)")
        task.resume()
        logger?.info("Background task for url request \(request) started: \(task)")
    }

    private func makeResponseCache(from tempFile: URL, of task: URLSessionTask) {
        do {
            let temporaryDirectory = FileManager.default.temporaryDirectory
            guard let jsonName = try task.originalRequest?.hashString() else {
                logger?.error("Could not get JSON name")
                return
            }
            let jsonFile = temporaryDirectory.appendingPathComponent("\(jsonName).\(task.taskIdentifier)")
            logger?.info("Renaming \(tempFile) to \(jsonFile)")
            try FileManager.default.moveItem(at: tempFile, to: jsonFile)
            requestFinished.send(jsonName)
        } catch {
            logger?.error("Error handling completed data task \(task): \(error)")
        }
    }
    
    func getResponseCache<T: Decodable>(for request: URLRequest) -> T? {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        do {
            let filename = try request.hashString()
            return try fileManager.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
                .first { $0.deletingPathExtension().lastPathComponent == filename }
                .map { try Data(contentsOf: $0) }
                .map { try JSONDecoder().decode(T.self, from: $0) }
        } catch {
            logger?.error("Could not get response for request \(request): \(error)")
            return nil
        }
    }
    
    func removeResponseCache(for request: URLRequest) throws {
        logger?.info("Remove cache file for request: \(request)")
        let filename = try request.hashString()
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        try fileManager.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
            .first { $0.deletingPathExtension().lastPathComponent == filename }
            .map { try fileManager.removeItem(at: $0) }
    }
}

extension BackgroundSessionManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        logger?.debug("Session download task \(downloadTask) finished downloading to location: \(location)")
        makeResponseCache(from: location, of: downloadTask)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        logger?.info("Background session finished events")
        backgroundSessionCompletion?()
    }
}

private extension URLRequest {
    func hashString() throws -> String {
        guard
            let url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems
        else {
            logger?.error("Failed to generate hash string for request: \(self)")
            throw BackgroundSessionManagerError.noRequestHashString(self)
        }
        
        let queryItemsString = queryItems
            .sorted(using: SortDescriptor(\.name))
            .map { $0.name + ($0.value ?? .empty) }
            .joined()
        
        return String((urlComponents.path + queryItemsString).sha256.prefix(16))
    }
}

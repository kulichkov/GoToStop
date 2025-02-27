//
//  CacheFileManager.swift
//  GoToStopAPI
//
//  Created by Mikhail Kulichkov on 24.02.25.
//

import Foundation

enum CacheFileManagerError: Error {
    case noCacheFolderFound
}

class CacheFileManager {
    nonisolated(unsafe) static let shared = CacheFileManager()
    
    private let serialQueue = DispatchQueue(label: "kulichkov.GoToStop.CacheFileManager")
    
    private func cacheDirectoryURL() throws -> URL {
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CacheFileManagerError.noCacheFolderFound
        }
        return url
    }
    
    private var fileManager: FileManager {
        .default
    }
    
    private init() {}
    
    func saveCacheFile(named filename: String, from tempFile: URL) throws {
        try serialQueue.sync {
            let jsonFile = try cacheDirectoryURL().appendingPathComponent("\(filename).json")
            try deleteFile(named: filename)
            logger?.info("Saving \(tempFile) to \(jsonFile)")
            try FileManager.default.copyItem(at: tempFile, to: jsonFile)
        }
    }
    
    func renameCacheFile(named oldFilename: String, to newFilename: String) throws {
        try serialQueue.sync {
            let oldJsonFile = try cacheDirectoryURL().appendingPathComponent("\(oldFilename).json")
            let newJsonFile = try cacheDirectoryURL().appendingPathComponent("\(newFilename).json")
            try deleteFile(named: newFilename)
            try fileManager.moveItem(at: oldJsonFile, to: newJsonFile)
        }
    }
    
    func getCachedData(named filename: String) throws -> Data? {
        try serialQueue.sync {
            let jsonFile = try cacheDirectoryURL().appendingPathComponent("\(filename).json")
            if fileManager.fileExists(atPath: jsonFile.path) {
                return try Data(contentsOf: jsonFile)
            } else {
                logger?.info("No file found at \(jsonFile)")
                return nil
            }
        }
    }
    
    func getCachedData<T: Decodable>(named filename: String) throws -> T? {
        try getCachedData(named: filename)
            .map { try JSONDecoder().decode(T.self, from: $0) }
    }
    
    func getCacheDate(named filename: String) throws -> Date? {
        try serialQueue.sync {
            let jsonFile = try cacheDirectoryURL().appendingPathComponent("\(filename).json")
            guard fileManager.fileExists(atPath: jsonFile.path) else {
                return nil
            }
            return try FileManager.default.attributesOfItem(atPath: jsonFile.path)[.creationDate] as? Date
        }
    }
    
    func getCacheFilenames() throws -> [String] {
        try serialQueue.sync {
            let cacheDirectoryURL = try self.cacheDirectoryURL()
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectoryURL, includingPropertiesForKeys: nil)
            return fileURLs
                .filter { $0.pathExtension == "json" }
                .map { $0.deletingPathExtension().lastPathComponent }
        }
    }
    
    func clearCacheFile(named filename: String) throws {
        try serialQueue.sync {
            try deleteFile(named: filename)
        }
    }
    
    func clearAllCacheFiles() throws {
        try serialQueue.sync {
            try getCacheFilenames().forEach {
                try deleteFile(named: $0)
            }
        }
    }
    
    private func deleteFile(named filename: String) throws {
        let jsonFile = try cacheDirectoryURL().appendingPathComponent("\(filename).json")
        if fileManager.fileExists(atPath: jsonFile.path) {
            try fileManager.removeItem(at: jsonFile)
        }
    }
}

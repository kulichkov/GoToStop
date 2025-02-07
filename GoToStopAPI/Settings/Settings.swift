//
//  Settings.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

public class Settings {
    private enum Key: String {
        case apiKey = "apiKey"
        case stopLocation = "stopLocation"
        case trips = "trips"
    }
    
    public static let shared = Settings()
    
    /// A suite name based on the AppGroup
    public let suiteName = "group.kulichkov.GoToStop"
    
    public lazy var apiKey: String? = getString(for: .apiKey) {
        didSet { setString(apiKey, for: .apiKey) }
    }
    
    public lazy var stopLocation: StopLocation? = getObject(for: .stopLocation) {
        didSet { setObject(stopLocation, for: .stopLocation) }
    }
    
    public lazy var trips: [Trip] = getObjects(for: .trips) {
        didSet { setObjects(trips, for: .trips) }
    }
    
    private lazy var userDefaults = UserDefaults(suiteName: suiteName)
    
    private init() {}
    
    private func getObject<T: Decodable>(for key: Settings.Key) -> T? {
        guard let data = userDefaults?.data(forKey: key.rawValue)
        else { return nil }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger?.error("\(error)")
            return nil
        }
    }
    
    private func setObject(_ object: Encodable?, for key: Settings.Key) {
        guard let object else {
            userDefaults?.set(nil, forKey: key.rawValue)
            return
        }
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults?.set(data, forKey: key.rawValue)
        } catch {
            logger?.error("Error saving object: \(error)")
        }
    }
    
    private func getObjects<T: Decodable>(for key: Settings.Key) -> [T] {
        guard let data = userDefaults?.data(forKey: key.rawValue)
        else { return [] }
        
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            logger?.error("\(error)")
            return []
        }
    }
    
    private func setObjects<T: Encodable>(_ objects: [T], for key: Settings.Key) {
        guard !objects.isEmpty else {
            userDefaults?.set([], forKey: key.rawValue)
            return
        }
        do {
            let data = try JSONEncoder().encode(objects)
            userDefaults?.set(data, forKey: key.rawValue)
        } catch {
            logger?.error("Error saving object: \(error)")
        }
    }
    
    private func getObjects<K: Hashable & Decodable, T: Decodable>(for key: Settings.Key) -> Dictionary<K, T> {
        guard let data = userDefaults?.data(forKey: key.rawValue)
        else { return [:] }
        
        do {
            return try JSONDecoder().decode(Dictionary<K, T>.self, from: data)
        } catch {
            logger?.error("\(error)")
            return [:]
        }
    }
    
    private func setObjects<K: Hashable & Encodable, T: Encodable>(_ objects: Dictionary<K, T>, for key: Settings.Key) {
        guard !objects.isEmpty else {
            userDefaults?.set([:], forKey: key.rawValue)
            return
        }
        do {
            let data = try JSONEncoder().encode(objects)
            userDefaults?.set(data, forKey: key.rawValue)
        } catch {
            logger?.error("Error saving object: \(error)")
        }
    }
    
    private func getString(for key: Settings.Key) -> String? {
        userDefaults?.string(forKey: key.rawValue)
    }
    
    private func setString(_ string: String?, for key: Settings.Key) {
        userDefaults?.set(string, forKey: key.rawValue)
    }
}

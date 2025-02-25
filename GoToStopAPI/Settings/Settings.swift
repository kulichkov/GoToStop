//
//  Settings.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import Foundation

public class Settings {
    public enum Key: String {
        case shouldCollectWidgetLogs = "shouldCollectWidgetLogs"
        case widgetLogsUrl = "widgetLogsUrl"
        case activeWidgetRequests = "activeWidgetRequests"
    }
    
    static public let container: UserDefaults = {
        UserDefaults(suiteName: Settings.suiteName) ?? .standard
    }()
    
    @propertyWrapper
    public struct Setting<Value: Codable> {
        let key: Key
        var container: UserDefaults { Settings.container }
        let defaultValue: Value

        public var wrappedValue: Value {
            get {
                container.getObject(for: key.rawValue) ?? defaultValue
            }
            set {
                container.setObject(newValue, for: key.rawValue)
            }
        }
    }
    
    public static let shared = Settings()
    public static let suiteName = "group.kulichkov.GoToStop"
        
    @Setting(key: .shouldCollectWidgetLogs, defaultValue: false)
    public var shouldCollectWidgetLogs: Bool
    
    @Setting(key: .widgetLogsUrl, defaultValue: nil)
    public var widgetLogsUrl: URL?
    
    @Setting(key: .activeWidgetRequests, defaultValue: Set<String>([]))
    public var activeWidgetRequests: Set<String>
    
    private init() {}
}

extension UserDefaults {
    fileprivate func getObject<T: Decodable>(for key: String) -> T? {
        guard let data = data(forKey: key)
        else { return nil }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger?.error("\(error)")
            return nil
        }
    }
    
    fileprivate func setObject(_ object: Encodable?, for key: String) {
        guard let object else {
            set(nil, forKey: key)
            return
        }
        do {
            let data = try JSONEncoder().encode(object)
            set(data, forKey: key)
        } catch {
            logger?.error("Error saving object: \(error)")
        }
    }
}

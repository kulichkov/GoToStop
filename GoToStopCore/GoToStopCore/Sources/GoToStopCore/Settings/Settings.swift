//
//  Settings.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import Foundation

public struct WidgetInfo: Hashable, Codable, Sendable {
    public let hashString: String
    public let lastReloadDate: Date
    public init(
        hashString: String,
        lastReloadDate: Date
    ) {
        self.hashString = hashString
        self.lastReloadDate = lastReloadDate
    }
}

public final class Settings: @unchecked Sendable {
    public enum Key: String {
        case shouldCollectWidgetLogs = "shouldCollectWidgetLogs"
        case widgetLogsUrl = "widgetLogsUrl"
        case activeWidgetRequests = "activeWidgetRequests"
        case widgetsReadyToReload = "widgetsReadyToReload"
        case widgetInfos = "widgetInfos"
    }
    
    static nonisolated(unsafe) public let container: UserDefaults = {
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
    
    @Setting(key: .widgetsReadyToReload, defaultValue: Set<String>([]))
    public var widgetsReadyToReload: Set<String>
    
    @Setting(key: .widgetInfos, defaultValue: Set<WidgetInfo>([]))
    public var widgetInfos: Set<WidgetInfo>
    
    private init() {}
}

extension UserDefaults {
    fileprivate func getObject<T: Decodable>(for key: String) -> T? {
        guard let data = data(forKey: key)
        else { return nil }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    fileprivate func setObject(_ object: Encodable?, for key: String) {
        guard let object else {
            set(nil, forKey: key)
            return
        }
        let data = try? JSONEncoder().encode(object)
        set(data, forKey: key)
    }
}

//
//  Settings.swift
//  GoToStop
//
//  Created by Mikhail Kulichkov on 20.12.24.
//

import Foundation

public class Settings {
    public enum Key: String {
        case isSharingLogs = "isSharingLogs"
    }
    
    @propertyWrapper
    public struct Setting<Value> {
        let key: Key
        let defaultValue: Value
        private var container: UserDefaults {
            UserDefaults(suiteName: Settings.suiteName) ?? .standard
        }

        public var wrappedValue: Value {
            get {
                container.object(forKey: key.rawValue) as? Value ?? defaultValue
            }
            set {
                container.set(newValue, forKey: key.rawValue)
            }
        }
    }
    
    public static let shared = Settings()
    public static let suiteName = "group.kulichkov.GoToStop"
        
    @Setting(key: .isSharingLogs, defaultValue: false)
    public var isSharingLogs: Bool
    
    private init() {}
}

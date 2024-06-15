// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public typealias Preferences = PreferencesStore

public class PreferencesStore {
    
    private let defaults: UserDefaults
    
    public struct Keys {
        static let explorerName = "explorer_name"
    }
    
    public static let standard = Preferences()
    
    public init(
        defaults: UserDefaults = UserDefaults.standard
    ) {
        self.defaults = defaults
    }
    
    public var hasCurrency: Bool {
        return defaults.object(forKey: "currency") != nil
    }
    
    @UserDefault(defaults: .standard, key: "currency", defaultValue: Currency.usd.rawValue)
    public var currency: String
    
    @UserDefault(defaults: .standard, key: "migrate_fiat_mappings_version", defaultValue: 0)
    public var importFiatMappingsVersion: Int
    
    @UserDefault(defaults: .standard, key: "migrate_fiat_purchase_assets_version", defaultValue: 0)
    public var importFiatPurchaseAssetsVersion: Int
    
    @UserDefault(defaults: .standard, key: "local_assets_version", defaultValue: 0)
    public var localAssetsVersion: Int
    
    @UserDefault(defaults: .standard, key: "fiat_assets_version", defaultValue: 0)
    public var fiatAssetsVersion: Int
    
    @UserDefault(defaults: .standard, key: "swap_assets_version", defaultValue: 0)
    public var swapAssetsVersion: Int
    
    @UserDefault(defaults: .standard, key: "launches_count", defaultValue: 0)
    public var launchesCount: Int
    
    @UserDefault(defaults: .standard, key: "subscriptions_version", defaultValue: 0)
    public var subscriptionsVersion: Int
    
    @UserDefault(defaults: .standard, key: "currentWallet", defaultValue: .none)
    public var currentWallet: String?
    
    @UserDefault(defaults: .standard, key: "is_push_notifications_enabled", defaultValue: false)
    public var isPushNotificationsEnabled: Bool
    
    @UserDefault(defaults: .standard, key: "is_subscriptions_enabled", defaultValue: true)
    public var isSubscriptionsEnabled: Bool
    
    @UserDefault(defaults: .standard, key: "rate_application_shown", defaultValue: false)
    public var rateApplicationShown: Bool
    
    @UserDefault(defaults: .standard, key: "is_developer_enabled", defaultValue: false)
    public var isDeveloperEnabled: Bool
    
    public func incrementLaunchesCount() {
        launchesCount = launchesCount + 1
    }
    
    public func setExplorerName(chain: Chain, name: String) {
        return defaults.setValue(name, forKey: "\(Keys.explorerName)_\(chain.rawValue)")
    }
    
    public func explorerName(chain: Chain) -> String? {
        return defaults.string(forKey: "\(Keys.explorerName)_\(chain.rawValue)")
    }
    
    public func clear() {
        defaults.dictionaryRepresentation().keys.forEach {
            defaults.removeObject(forKey: $0)
        }
    }
}

@propertyWrapper
public struct UserDefault<T> {
    var defaults: UserDefaults
    let key: String
    let defaultValue: T
    
    public var wrappedValue: T {
        get {
            guard let value = defaults.object(forKey: key) as? T else {
                return defaultValue
            }
            return value
        }
        set {
            if let optionalValue = newValue as? AnyOptional, optionalValue.isNil {
                defaults.removeObject(forKey: key)
            } else {
                defaults.set(newValue, forKey: key)
            }
        }
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        return self == nil
    }
}


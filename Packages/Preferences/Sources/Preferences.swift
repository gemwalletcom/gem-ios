// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public final class Preferences: @unchecked Sendable {
    private struct Keys {
        static let currency = "currency"
        static let importFiatMappingsVersion = "migrate_fiat_mappings_version"
        static let importFiatPurchaseAssetsVersion = "migrate_fiat_purchase_assets_version"
        static let localAssetsVersion = "local_assets_version"
        static let fiatOnRampAssetsVersion = "fiat_on_ramp_assets_version"
        static let fiatOffRampAssetsVersion = "fiat_off_ramp_assets_version"
        static let swapAssetsVersion = "swap_assets_version"
        static let launchesCount = "launches_count"
        static let subscriptionsVersion = "subscriptions_version"
        static let currentWalletId = "currentWallet"
        static let isPushNotificationsEnabled = "is_push_notifications_enabled"
        static let isPriceAlertsEnabled = "is_price_alerts_enabled"
        static let isSubscriptionsEnabled = "is_subscriptions_enabled"
        static let rateApplicationShown = "rate_application_shown"
        static let authenticationLockOption = "authentication_lock_option"
        static let isDeveloperEnabled = "is_developer_enabled"
        static let isHideBalanceEnabled = "is_balance_privacy_enabled"
    }

    @ConfigurableDefaults(key: Keys.currency, defaultValue: Currency.usd.rawValue)
    public var currency: String
    
    @ConfigurableDefaults(key: Keys.importFiatMappingsVersion, defaultValue: 0)
    public var importFiatMappingsVersion: Int
    
    @ConfigurableDefaults(key: Keys.importFiatPurchaseAssetsVersion, defaultValue: 0)
    public var importFiatPurchaseAssetsVersion: Int
    
    @ConfigurableDefaults(key: Keys.localAssetsVersion, defaultValue: 0)
    public var localAssetsVersion: Int
    
    @ConfigurableDefaults(key: Keys.fiatOnRampAssetsVersion, defaultValue: 0)
    public var fiatOnRampAssetsVersion: Int
    
    @ConfigurableDefaults(key: Keys.fiatOffRampAssetsVersion, defaultValue: 0)
    public var fiatOffRampAssetsVersion: Int
    
    @ConfigurableDefaults(key: Keys.swapAssetsVersion, defaultValue: 0)
    public var swapAssetsVersion: Int
    
    @ConfigurableDefaults(key: Keys.launchesCount, defaultValue: 0)
    public var launchesCount: Int
    
    @ConfigurableDefaults(key: Keys.subscriptionsVersion, defaultValue: 0)
    public var subscriptionsVersion: Int
    
    @ConfigurableDefaults(key: Keys.currentWalletId, defaultValue: .none)
    public var currentWalletId: String?
    
    @ConfigurableDefaults(key: Keys.isPushNotificationsEnabled, defaultValue: false)
    public var isPushNotificationsEnabled: Bool

    @ConfigurableDefaults(key: Keys.isPriceAlertsEnabled, defaultValue: false)
    public var isPriceAlertsEnabled: Bool

    @ConfigurableDefaults(key: Keys.isSubscriptionsEnabled, defaultValue: true)
    public var isSubscriptionsEnabled: Bool
    
    @ConfigurableDefaults(key: Keys.rateApplicationShown, defaultValue: false)
    public var rateApplicationShown: Bool

    @ConfigurableDefaults(key: Keys.authenticationLockOption, defaultValue: 0)
    public var authenticationLockOption: Int

    @ConfigurableDefaults(key: Keys.isDeveloperEnabled, defaultValue: false)
    public var isDeveloperEnabled: Bool

    @ConfigurableDefaults(key: Keys.isHideBalanceEnabled, defaultValue: false)
    public var isHideBalanceEnabled: Bool

    public static let standard = Preferences()
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults

        // configure each @ConfigurableDefaults with injected defaults
        Mirror(reflecting: self).children
            .compactMap { $0.value as? ConfigurableUserDefaults }
            .forEach { $0.configure(with: defaults) }
    }
}

// MARK: - Explorer

extension Preferences {
    private struct ExplorerKeys {
        static let explorerName = "explorer_name"
    }

    public func setExplorerName(chain: Chain, name: String) {
        defaults.setValue(name, forKey: "\(ExplorerKeys.explorerName)_\(chain.rawValue)")
    }

    public func explorerName(chain: Chain) -> String? {
        defaults.string(forKey: "\(ExplorerKeys.explorerName)_\(chain.rawValue)")
    }
}

extension Preferences {
    public func incrementLaunchesCount() {
        launchesCount = launchesCount + 1
    }

    public var hasCurrency: Bool {
        defaults.object(forKey: Keys.currency) != nil
    }

    public func clear() {
        defaults.dictionaryRepresentation().keys.forEach {
            defaults.removeObject(forKey: $0)
        }
    }
}

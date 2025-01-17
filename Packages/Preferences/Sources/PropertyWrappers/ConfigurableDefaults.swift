// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol ConfigurableUserDefaults {
    func configure(with: UserDefaults)
}

@propertyWrapper
public final class ConfigurableDefaults<T>: @unchecked Sendable, ConfigurableUserDefaults {
    let key: String
    let defaultValue: T

    private var defaults: UserDefaults?

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            guard let userDefaults = defaults else {
                return defaultValue
            }
            return userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            defaults?.set(newValue, forKey: key)
        }
    }

    public func configure(with userDefaults: UserDefaults) {
        self.defaults = userDefaults
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        self == nil
    }
}

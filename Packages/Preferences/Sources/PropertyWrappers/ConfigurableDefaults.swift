// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@propertyWrapper
public struct ConfigurableDefaults<T>: @unchecked Sendable {
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

    public mutating func configure(with userDefaults: UserDefaults) {
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

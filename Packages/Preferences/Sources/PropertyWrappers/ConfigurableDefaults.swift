// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@propertyWrapper
public struct ConfigurableDefaults<T>: @unchecked Sendable {
    private let key: String
    private let defaultValue: T
    private let defaults: UserDefaults
    private let sharedDefaults: UserDefaults?

    public init(
        key: String,
        defaultValue: T,
        defaults: UserDefaults = .standard,
        sharedDefaults: UserDefaults? = nil
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
        self.sharedDefaults = sharedDefaults
    }

    public var wrappedValue: T {
        get {
            defaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            let value = (newValue as? AnyOptional)?.isNil == true ? nil : newValue
            defaults.set(value, forKey: key)
            if let sharedDefaults = sharedDefaults {
                sharedDefaults.set(value, forKey: key)
            }
        }
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

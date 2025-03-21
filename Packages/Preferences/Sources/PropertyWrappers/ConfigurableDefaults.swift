// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@propertyWrapper
public struct ConfigurableDefaults<T>: @unchecked Sendable {
    private let key: String
    private let defaultValue: T
    private let defaults: UserDefaults

    public init(
        key: String,
        defaultValue: T,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get {
            defaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            defaults.set(
                (newValue as? AnyOptional)?.isNil == true ? nil : newValue,
                forKey: key
            )
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

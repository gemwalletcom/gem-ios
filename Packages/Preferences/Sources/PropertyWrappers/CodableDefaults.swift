// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@propertyWrapper
public struct CodableDefaults<T: Codable>: @unchecked Sendable {
    private let key: String
    private let defaults: UserDefaults

    public init(
        key: String,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaults = defaults
    }

    public var wrappedValue: T? {
        get {
            guard let data = defaults.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences

public final class MockKeychainPreference: KeychainPreferenceStorable, @unchecked Sendable {
    private let storage: UserDefaults

    init(storage: UserDefaults) {
        self.storage = storage
    }

    public func set(value: String, key: String) throws {
        storage.set(value, forKey: key)
    }

    public func get(key: String) throws -> String? {
        storage.string(forKey: key)
    }

    public func set(_ value: Data, key: String) throws {
        storage.set(value, forKey: key)
    }

    public func getData(key: String) throws -> Data? {
        storage.data(forKey: key)
    }

    public func remove(key: String) throws {
        storage.removeObject(forKey: key)
    }
}

public extension MockKeychainPreference {
    static func mock(storage: UserDefaults = .mock()) -> any KeychainPreferenceStorable {
        MockKeychainPreference(storage: storage)
    }
}

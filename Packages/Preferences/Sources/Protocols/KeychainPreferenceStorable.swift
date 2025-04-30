// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol KeychainPreferenceStorable: Sendable {
    func set(value: String, key: String) throws
    func get(key: String) throws -> String?
    func remove(key: String) throws
}

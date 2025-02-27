// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol FileStorable: Sendable {
    func value<T: Decodable>(for key: FileStorageKey) throws -> T?
    func store<T: Encodable>(value: T, for key: FileStorageKey) throws
    func remove(for key: FileStorageKey) throws
}

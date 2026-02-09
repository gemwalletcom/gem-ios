// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

public protocol DatabaseQueryable: Equatable, Sendable {
    associatedtype Value: Equatable & Sendable
    @MainActor static var defaultValue: Value { get }
    func fetch(_ db: Database) throws -> Value
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

public protocol ValueObservable: Sendable {
    associatedtype Value: Sendable
    func fetch(_ db: Database) throws -> Value
}

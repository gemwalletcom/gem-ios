// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

public protocol BindableQuery: AnyObject, Sendable {
    @MainActor func bind(dbQueue: DatabaseQueue)
}

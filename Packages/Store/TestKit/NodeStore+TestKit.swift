// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import Store

public extension NodeStore {
    static func mock(db: DB = .mock()) -> Self {
        NodeStore(db: db)
    }
}

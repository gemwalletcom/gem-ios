// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension NFTStore {
    static func mock(db: DB = .mock()) -> NFTStore {
        NFTStore(db: db)
    }
}

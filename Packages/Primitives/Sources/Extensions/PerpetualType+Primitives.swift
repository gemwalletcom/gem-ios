// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension PerpetualType {
    var baseAsset: Asset {
        switch self {
        case .open(let data), .close(let data): data.baseAsset
        case .modify(let data): data.baseAsset
        }
    }
}

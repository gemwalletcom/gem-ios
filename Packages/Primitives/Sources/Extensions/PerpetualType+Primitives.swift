// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension PerpetualType {
    var baseAsset: Asset {
        switch self {
        case .open(let data): data.baseAsset
        case .close(let data): data.baseAsset
        case .autoclose(let data): data.baseAsset
        }
    }
}

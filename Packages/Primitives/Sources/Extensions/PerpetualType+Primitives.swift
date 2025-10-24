// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension PerpetualType {
    var baseAsset: Asset {
        data.baseAsset
    }

    var data: PerpetualConfirmData {
        switch self {
        case .open(let data), .close(let data): data
        }
    }
}

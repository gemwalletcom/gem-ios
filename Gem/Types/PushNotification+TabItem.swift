// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

extension PushNotification {
    var selectTab: TabItem? {
        switch self {
        case .transaction, .asset, .priceAlert: .wallet
        case .buyAsset, .swapAsset: nil
        case .support, .rewards: .settings
        case .test, .unknown: nil
        }
    }
}

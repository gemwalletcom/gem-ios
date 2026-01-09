// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

extension DeepLinkAction {
    var selectTab: TabItem? {
        switch self {
        case .asset, .perpetuals: .wallet
        case .swap, .buy, .sell, .setPriceAlert: nil
        case .rewards, .gift: .settings
        }
    }
}

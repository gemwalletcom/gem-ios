// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletSubscription {
    public var asWalletSubscriptionChains: WalletSubscriptionChains {
        WalletSubscriptionChains(
            wallet_id: wallet_id,
            chains: subscriptions.map(\.chain)
        )
    }
}

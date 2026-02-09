// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletSubscription {
    public var asWalletSubscriptionChains: WalletSubscriptionChains {
        WalletSubscriptionChains(
            walletId: walletId,
            chains: subscriptions.map(\.chain).sorted()
        )
    }
}

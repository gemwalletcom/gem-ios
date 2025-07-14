// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct SwapInput {
    let wallet: Wallet
    let pairSelector: SwapPairSelectorViewModel

    public init(wallet: Wallet, pairSelector: SwapPairSelectorViewModel) {
        self.wallet = wallet
        self.pairSelector = pairSelector
    }
}

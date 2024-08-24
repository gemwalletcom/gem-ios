// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct BannerSetupService {

    let store: BannerStore

    init(store: BannerStore) {
        self.store = store
    }

    func setup() throws {
        // Adding staking for all chains
        for chain in StakeChain.allCases {
            try store.addBanner(
                Banner(wallet: .none, asset: chain.chain.asset, event: .stake, state: .active)
            )
        }
    }

    func setupWallet(wallet: Wallet) throws  {
        // Adding XRP activation fee banner
        try store.addBanner(
            Banner(wallet: wallet, asset: Chain.xrp.asset, event: .accountActivation, state: .active)
        )
    }
}

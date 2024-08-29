// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct BannerSetupService {

    let store: BannerStore
    let preferences: Preferences

    init(
        store: BannerStore,
        preferences: Preferences = .main
    ) {
        self.store = store
        self.preferences = preferences
    }

    func setup() throws {
        // Adding staking for all chains

//TODO: Enable when deep links to staking work
//        for chain in StakeChain.allCases {
//            try store.addBanner(
//                Banner(wallet: .none, asset: chain.chain.asset, event: .stake, state: .active)
//            )
//        }

        // Enable push notifications
//        if !preferences.isPushNotificationsEnabled && preferences.launchesCount > 2 {
//            try store.addBanner(
//                Banner(wallet: .none, asset: .none, event: .enableNotifications, state: .active)
//            )
//        }
    }

    func setupWallet(wallet: Wallet) throws  {
        // Adding XRP activation fee banner
        try store.addBanner(
            Banner(wallet: wallet, asset: Chain.xrp.asset, event: .accountActivation, state: .active)
        )
    }
}

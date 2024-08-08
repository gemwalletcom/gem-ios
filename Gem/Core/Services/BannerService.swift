// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

struct BannerService {

    let store: BannerStore

    init(store: BannerStore) {
        self.store = store
    }

    func closeBanner(banner: Banner) throws {
        try updateState(banner: banner, state: .cancelled)
    }

    func updateState(banner: Banner, state: BannerState) throws {
        let _ = try store.updateState(banner.id, state: state)
    }

    func setup() {
//        let banner1 = Banner(wallet: .none, asset: Chain.cosmos.asset, event: .stake, state: .active)
//        let banner2 = Banner(wallet: .none, asset: Chain.xrp.asset, event: .accountActivation, state: .active)
//        let banner3 = Banner(wallet: .none, asset: .none, event: .stake, state: .active)
//
//        try! store.addBanner(banner1)
//        try! store.addBanner(banner2)
//        try! store.addBanner(banner3)
    }
}

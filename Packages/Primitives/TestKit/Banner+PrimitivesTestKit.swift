// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Banner {
    static func mock(
        wallet: Wallet? = .mock(),
        asset: Asset? = .mock(),
        chain: Chain? = .bitcoin,
        event: BannerEvent = .stake,
        state: BannerState = .active
    ) -> Banner {
        Banner(
            wallet: wallet,
            asset: asset,
            chain: chain,
            event: event,
            state: state
        )
    }
}
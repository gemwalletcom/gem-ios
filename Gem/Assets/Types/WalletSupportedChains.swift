// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

struct WalletSupportedChains {
    private let chains: [Chain]

    init(wallet: Wallet) {
        let walletChains = wallet.accounts.map { $0.chain }.asSet()
        let supportedChains = AssetConfiguration.supportedChainsWithTokens

        self.chains = walletChains.intersection(supportedChains).asArray()
    }

    var sortedByRank: [Chain] {
        chains.sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }

    var hasMany: Bool {
        chains.count > 1
    }

    var hasOne: Bool {
        chains.count == 1
    }

    var isEmpty: Bool {
        chains.isEmpty
    }
}


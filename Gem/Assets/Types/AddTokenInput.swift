// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Settings

struct AddTokenInput {
    let availableChains: [Chain]

    var chain: Chain?
    var address: String?

    init(wallet: Wallet) {
        self.availableChains = AssetConfiguration.supportedChainsWithTokens.asSet()
            .intersection(
                wallet.accounts.map { $0.chain }.asSet()
            ).asArray().sorted { chain1, chain2 in
                AssetScore.defaultRank(chain: chain1) > AssetScore.defaultRank(chain: chain2)
            }

        // set default chain
        self.chain = availableChains.first
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Wallet {
    var chains: [Chain] {
        let walletChains = accounts.map { $0.chain }.asSet()
        return walletChains.intersection(AssetConfiguration.allChains).asArray()
            .sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }

    var chainsWithTokens: [Chain] {
        let walletChains = accounts.map { $0.chain }.asSet()
        return walletChains.intersection(AssetConfiguration.supportedChainsWithTokens).asArray()
            .sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }
}

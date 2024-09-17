// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings

enum WalletSupportedChains {
    case all
    case withTokens
}

// MARK: - Model extensions

extension Primitives.Wallet {
    func chains(type: WalletSupportedChains) -> [Chain] {
        let supportedChains: [Chain]
        switch type {
        case .all:
            supportedChains = AssetConfiguration.allChains
        case .withTokens:
            supportedChains = AssetConfiguration.supportedChainsWithTokens
        }

        let walletChains = accounts.map { $0.chain }.asSet()
        return walletChains.intersection(supportedChains).asArray()
            .sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }
}

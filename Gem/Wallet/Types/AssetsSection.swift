// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AssetsSections {
    let pinned: [AssetData]
    let assets: [AssetData]
    let popular: [AssetData]
    
    private static let popularChains = Set<AssetId>(arrayLiteral: Chain.bitcoin.assetId, Chain.ethereum.assetId, Chain.solana.assetId)
}

extension AssetsSections {
    static func from(_ assets: [AssetData]) -> AssetsSections {
        AssetsSections(
            pinned: assets.filter { $0.metadata.isPinned },
            assets: assets.filter { !$0.metadata.isPinned },
            popular: assets.filter { Self.popularChains.contains($0.asset.id) }
        )
    }
}

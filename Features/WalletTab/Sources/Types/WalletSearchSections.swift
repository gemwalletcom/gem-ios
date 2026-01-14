// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct WalletSearchSections: Equatable, Sendable {
    public let pinnedAssets: [AssetData]
    public let assets: [AssetData]
    
    public let pinnedPerpetuals: [PerpetualData]
    public let perpetuals: [PerpetualData]

    public static func from(_ result: WalletSearchResult) -> WalletSearchSections {
        let (pinnedAssets, assets) = result.assets.reduce(into: ([AssetData](), [AssetData]())) {
            if $1.metadata.isPinned {
                $0.0.append($1)
            } else {
                $0.1.append($1)
            }
        }
        let (pinnedPerpetuals, perpetuals) = result.perpetuals.reduce(into: ([PerpetualData](), [PerpetualData]())) {
            if $1.metadata.isPinned {
                $0.0.append($1)
            } else {
                $0.1.append($1)
            }
        }
        return WalletSearchSections(
            pinnedAssets: pinnedAssets,
            assets: assets,
            pinnedPerpetuals: pinnedPerpetuals,
            perpetuals: perpetuals
        )
    }
}

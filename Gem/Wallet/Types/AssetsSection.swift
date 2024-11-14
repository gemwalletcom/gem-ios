// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AssetsSections {
    let pinned: [AssetData]
    let assets: [AssetData]
}

extension AssetsSections {
    static func from(_ assets: [AssetData]) -> AssetsSections {
        AssetsSections(
            pinned: assets.filter { $0.metadata.isPinned },
            assets: assets
        )
    }
}

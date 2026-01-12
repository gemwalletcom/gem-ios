// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct WalletSearchSections: Equatable, Sendable {
    public let pinned: [AssetData]
    public let assets: [AssetData]
    public let perpetuals: [PerpetualData]

    public static func from(_ result: WalletSearchResult) -> WalletSearchSections {
        let (pinned, assets) = result.assets.reduce(into: ([AssetData](), [AssetData]())) {
            if $1.metadata.isPinned {
                $0.0.append($1)
            } else {
                $0.1.append($1)
            }
        }
        return WalletSearchSections(pinned: pinned, assets: assets, perpetuals: result.perpetuals)
    }
}

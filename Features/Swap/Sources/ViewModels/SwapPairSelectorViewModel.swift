// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct SwapPairSelectorViewModel: Equatable {
    var fromAssetId: AssetId?
    var toAssetId: AssetId?

    init(
        fromAssetId: AssetId?,
        toAssetId: AssetId?
    ) {
        self.fromAssetId = fromAssetId
        self.toAssetId = toAssetId
    }
}

extension SwapPairSelectorViewModel {
    static func defaultSwapPair(for asset: Asset) -> SwapPairSelectorViewModel {
        if asset.type == .native {
            return SwapPairSelectorViewModel(
                fromAssetId: asset.chain.assetId,
                toAssetId: nil
            )
        }
        return SwapPairSelectorViewModel(
            fromAssetId: asset.id,
            toAssetId: asset.chain.assetId
        )
    }
}

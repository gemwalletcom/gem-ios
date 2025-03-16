// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives

public struct SwapPairSelectorViewModel: Equatable {
    public var fromAssetId: AssetId?
    public var toAssetId: AssetId?
    
    public init(
        fromAssetId: AssetId?,
        toAssetId: AssetId?
    ) {
        self.fromAssetId = fromAssetId
        self.toAssetId = toAssetId
    }
}

extension SwapPairSelectorViewModel {
    public static func defaultSwapPair(for asset: Asset) -> SwapPairSelectorViewModel {
        if asset.type == .native {
            return SwapPairSelectorViewModel(
                fromAssetId: asset.chain.assetId,
                toAssetId: Chain.allCases
                    .sortByRank()
                    .first(where: { $0.asset != asset })?.assetId
            )
        }
        return SwapPairSelectorViewModel(
            fromAssetId: asset.id,
            toAssetId: asset.chain.assetId
        )
    }
}

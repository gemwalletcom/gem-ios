// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SwapPairSelectorViewModel: Equatable {
    var fromAssetId: AssetId?
    var toAssetId: AssetId?

    public init(
        fromAssetId: AssetId?,
        toAssetId: AssetId?
    ) {
        self.fromAssetId = fromAssetId
        self.toAssetId = toAssetId
    }
}

public extension SwapPairSelectorViewModel {
    static func defaultSwapPair(for asset: Asset) -> SwapPairSelectorViewModel {
        if asset.type == .native {
            if ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"] != nil {
                return SwapPairSelectorViewModel(
                    fromAssetId: asset.chain.assetId,
                    toAssetId: AssetId(chain: .ethereum)
                )
            }
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

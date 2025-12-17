// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ChainAssetData {
    static func mock(
        assetData: AssetData = .mock(),
        feeAssetData: AssetData = .mock()
    ) -> ChainAssetData {
        ChainAssetData(
            assetData: assetData,
            feeAssetData: feeAssetData
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
class SwapPairSelectorViewModel {
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

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
public class SwapPairSelectorViewModel {
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

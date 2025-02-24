// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct CollectibleNavigationViewModel {
    public let wallet: Wallet
    public let assetData: NFTAssetData
    
    public init(
        wallet: Wallet,
        assetData: NFTAssetData
    ) {
        self.wallet = wallet
        self.assetData = assetData
    }
}

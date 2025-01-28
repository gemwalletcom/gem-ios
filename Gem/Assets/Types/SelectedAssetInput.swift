// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct SelectedAssetInput: Hashable {
    let type: SelectedAssetType
    let assetAddress: AssetAddress
    
    var asset: Asset  {
        assetAddress.asset
    }
    
    var address: String {
        assetAddress.address
    }
    
    init(type: SelectedAssetType, assetAddress: AssetAddress) {
        self.type = type
        self.assetAddress = assetAddress
    }
}

extension SelectedAssetInput: Identifiable {
    var id: String { type.id }
}

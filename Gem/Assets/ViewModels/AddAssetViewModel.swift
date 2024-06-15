// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
//import Gemstone
import GemstonePrimitives

struct AddAssetViewModel {
    let asset: Asset
    
    var name: String { asset.name }
    var symbol: String { asset.symbol }
    var decimals: String { asset.decimals.asString }
    var type: String { asset.id.assetType?.rawValue ?? "" }
    
    private var tokenLink: BlockExplorerLink? {
        ExplorerService.main.tokenUrl(chain: asset.chain, address: asset.tokenId ?? "")
    }
    
    var explorerUrl: URL? {
        tokenLink?.url
    }
    
    var explorerText: String? {
        Localized.Transaction.viewOn(name)
    }
}

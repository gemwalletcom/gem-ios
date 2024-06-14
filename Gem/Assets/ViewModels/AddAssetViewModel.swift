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
    var url: URL? {
        guard let explorerUrl = ExplorerService.main.tokenUrl(chain: asset.chain, address: asset.tokenId ?? "") else {
            return .none
        }
        return explorerUrl.url
    }
}

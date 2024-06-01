// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

struct AddAssetViewModel {
    let asset: Asset
    
    var name: String { asset.name }
    var symbol: String { asset.symbol }
    var decimals: String { asset.decimals.asString }
    var type: String { asset.id.assetType?.rawValue ?? "" }
    var url: URL? {
        guard 
            let explorerUrl = Gemstone.Explorer().getTokenUrl(chain: asset.chain.rawValue, address: asset.tokenId ?? ""),
            let url = URL(string: explorerUrl)  else {
                return .none
        }
        return url
    }
}

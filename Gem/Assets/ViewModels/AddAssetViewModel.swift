// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import ExplorerService

struct AddAssetViewModel {
    let asset: Asset
    let explorerService: ExplorerService = .standart

    var nameTitle: String { Localized.Asset.name }
    var symbolTitle: String { Localized.Asset.symbol }
    var decimalsTitle: String { Localized.Asset.decimals }
    var typeTitle: String { Localized.Common.type }

    var explorerText: String? { Localized.Transaction.viewOn(name) }

    var name: String { asset.name }
    var symbol: String { asset.symbol }
    var decimals: String { asset.decimals.asString }
    var type: String { asset.id.assetType?.rawValue ?? "" }
    
    var explorerUrl: URL? {
        explorerService.tokenUrl(chain: asset.chain, address: asset.tokenId ?? "")?.url
    }
}

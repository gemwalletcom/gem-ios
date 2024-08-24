// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AssetDetailsInfoViewModel {
    let asset: Asset
    let details: AssetDetailsInfo

    var marketValues: [(title: String, subtitle: String?)] {
        return [
            (title: Localized.Asset.marketCap, subtitle: marketCapText),
            (title: Localized.Asset.circulatingSupply, subtitle: circulatingSupplyText),
            (title: Localized.Asset.totalSupply, subtitle: totalSupplyText),
        ].filter { $0.subtitle?.isEmpty == false }
    }

    var marketCapText: String? {
        if let marketCap = details.market.marketCap {
            return CurrencyFormatter.currency().string(marketCap)
        }
        return .none
    }

    var circulatingSupplyText: String?  {
        if let circulatingSupply = details.market.circulatingSupply {
            return IntegerFormatter.standard.string(circulatingSupply, symbol: asset.symbol)
        }
        return .none
    }

    var totalSupplyText: String? {
        if let totalSupply = details.market.totalSupply {
            return IntegerFormatter.standard.string(totalSupply, symbol: asset.symbol)
        }
        return .none
    }
}

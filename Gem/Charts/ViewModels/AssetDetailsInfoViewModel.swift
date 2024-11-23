// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Gemstone

struct AssetDetailsInfoViewModel {
    let priceData: PriceData

    var showLinksSection: Bool { !links.isEmpty }
    var showMarketValues: Bool { !marketValues.isEmpty }
    
    var linksSectionText: String { Localized.Social.links }

    func communityLink(for value: String) -> SocialUrl? {
        switch value {
        case "x": .x
        case "discord": .discord
        case "reddit": .reddit
        case "telegram": .telegram
        case "youTube": .youTube
        case "facebook": .facebook
        case "website": .website
        case "coingecko": .coingecko
        default: .none
        }
    }
    
    var links: [CommunityLink] {
        return priceData.links.map {
            if let type = communityLink(for: $0.name),
               let url = URL(string: $0.url) {
                    return CommunityLink(type: type, url: url)
            }
            return .none
        }.compactMap { $0 }.sorted()
    }
    
    var marketValues: [(title: String, subtitle: String?)] {
        return [
            (title: Localized.Asset.marketCap, subtitle: marketCapText),
            (title: Localized.Asset.circulatingSupply, subtitle: circulatingSupplyText),
            (title: Localized.Asset.totalSupply, subtitle: totalSupplyText),
        ].filter { $0.subtitle?.isEmpty == false }
    }

    var marketCapText: String? {
        if let marketCap = priceData.market?.marketCap {
            return CurrencyFormatter.currency().string(marketCap)
        }
        return .none
    }

    var circulatingSupplyText: String?  {
        if let circulatingSupply = priceData.market?.circulatingSupply {
            return IntegerFormatter.standard.string(circulatingSupply, symbol: priceData.asset.symbol)
        }
        return .none
    }

    var totalSupplyText: String? {
        if let totalSupply = priceData.market?.totalSupply {
            return IntegerFormatter.standard.string(totalSupply, symbol: priceData.asset.symbol)
        }
        return .none
    }
}

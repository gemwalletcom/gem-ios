// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import SwiftUI
import Style
import Components

struct AssetLinkViewModel {
    let assetLink: AssetLink

    init(_ assetLink: AssetLink) {
        self.assetLink = assetLink
    }

    var insightLink: InsightLink? {
        guard let name, let url, let image else {
            return .none
        }
        return InsightLink(
            title: name,
            subtitle: host,
            url: url,
            deepLink: deepLink,
            image: AssetImage.image(image)
        )
    }
    
    var name: String? {
        switch assetLink.linkType {
        case .x: Localized.Social.x
        case .discord: Localized.Social.discord
        case .reddit: Localized.Social.reddit
        case .telegram: Localized.Social.telegram
        case .gitHub: Localized.Social.github
        case .youTube: Localized.Social.youtube
        case .facebook: Localized.Social.facebook
        case .website: Localized.Social.website
        case .coingecko: Localized.Social.coingecko
        case .coinMarketCap: Localized.Social.coinmarketcap
        case .openSea: Localized.Social.opensea
        case .instagram: Localized.Social.instagram
        case .magicEden: Localized.Social.magiceden
        case .tikTok: Localized.Social.tiktok
        case .none: nil
        }
    }
    
    var image: Image? {
        switch assetLink.linkType {
        case .x: Images.Social.x
        case .discord: Images.Social.discord
        case .reddit: Images.Social.reddit
        case .telegram: Images.Social.telegram
        case .gitHub: Images.Social.github
        case .youTube: Images.Social.youtube
        case .facebook: Images.Social.facebook
        case .website: Images.Social.website
        case .coingecko: Images.Social.coingecko
        case .coinMarketCap: Images.Social.coinmarketcap
        case .openSea: Images.Social.opensea
        case .instagram: Images.Social.instagram
        case .magicEden: Images.Social.magiceden
        case .tikTok: Images.Social.tiktok
        case .none: nil
        }
    }
    
    var url: URL? {
        assetLink.url.asURL
    }
    
    var deepLink: URL? {
        DeepLinkViewModel(assetLink).deepLink
    }
    
    var host: String? {
        if case .website = assetLink.linkType {
            return assetLink.url.asURL?.cleanHost()
        }
        return nil
    }
}

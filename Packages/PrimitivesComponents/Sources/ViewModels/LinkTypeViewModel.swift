// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import SwiftUI
import Style

public struct LinkTypeViewModel {
    public let link: LinkType
    
    public init(link: LinkType) {
        self.link = link
    }
    
    public var order: Int {
        link.order
    }
    
    public var name: String {
        switch link {
        case .x: Localized.Social.x
        case .discord: Localized.Social.discord
        case .reddit: Localized.Social.reddit
        case .telegram: Localized.Social.github
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
        }
    }
    
    public var image: Image {
        switch link {
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
        }
    }
}

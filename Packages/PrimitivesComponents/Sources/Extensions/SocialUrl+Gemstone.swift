// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import Gemstone
import Localization
import Style
import SwiftUI

extension SocialUrl {
    public var name: String {
        switch self {
        case .x: Localized.Social.x
        case .discord: Localized.Social.discord
        case .telegram: Localized.Social.telegram
        case .gitHub: Localized.Social.github
        case .youTube: Localized.Social.youtube
        case .reddit: Localized.Social.reddit
        case .facebook: Localized.Social.facebook
        case .website: Localized.Social.website
        case .coingecko: Localized.Social.coingecko
        }
    }

    public var image: Image {
        switch self {
        case .x: Images.Social.x
        case .discord: Images.Social.discord
        case .telegram: Images.Social.telegram
        case .gitHub: Images.Social.github
        case .youTube: Images.Social.youtube
        case .reddit: Images.Social.reddit
        case .facebook: Images.Social.facebook
        case .website: Images.Social.website
        case .coingecko: Images.Social.coingecko
        }
    }

    public var order: Int {
        socialUrlOrder(url: self).asInt
    }
}

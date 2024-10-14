// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import SwiftUI
import Localization

struct CommunityLink {
    let type: SocialUrl
    let url: URL
}

extension CommunityLink: Comparable {
    static func <(lhs: CommunityLink, rhs: CommunityLink) -> Bool {
        return lhs.type.order > rhs.type.order
    }
}

extension CommunityLink: Identifiable {
    var id: String { type.name }
}

extension SocialUrl {
    var name: String {
        switch self {
        case .x: Localized.Social.x
        case .discord: Localized.Social.discord
        case .telegram: Localized.Social.telegram
        case .gitHub: Localized.Social.github
        case .youTube: Localized.Social.youtube
        case .reddit: Localized.Social.reddit
        case .facebook: Localized.Social.facebook
        case .homepage: Localized.Social.homepage
        case .coingecko: Localized.Social.coingecko
        }
    }
    
    var image: Image {
        switch self {
        case .x: Image(.x)
        case .discord: Image(.discord)
        case .telegram: Image(.telegram)
        case .gitHub: Image(.github)
        case .youTube: Image(.youtube)
        case .reddit: Image(.reddit)
        case .facebook: Image("facebook")
        case .homepage: Image("homepage")
        case .coingecko: Image(.coingecko)
        }
    }
    
    var order: Int {
        switch self {
        case .coingecko: 110
        case .x: 100
        case .discord: 60
        case .telegram: 90
        case .gitHub: 20
        case .youTube: 30
        case .reddit: 50
        case .facebook: 40
        case .homepage: 20
        }
    }
}

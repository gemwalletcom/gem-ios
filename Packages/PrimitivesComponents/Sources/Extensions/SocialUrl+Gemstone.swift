// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Localization
import Style
import SwiftUI
import Primitives

extension SocialUrl {
    
    public var linkType: LinkType {
        switch self {
        case .x: .x
        case .discord: .discord
        case .telegram: .telegram
        case .gitHub: .gitHub
        case .youTube: .youTube
        case .reddit: .reddit
        case .facebook: .facebook
        case .website: .website
        case .coingecko: .coingecko
        }
    }
}

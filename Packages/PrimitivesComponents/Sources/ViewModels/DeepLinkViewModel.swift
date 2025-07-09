// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct DeepLinkViewModel {
    public let assetLink: AssetLink
    
    public init(_ assetLink: AssetLink) {
        self.assetLink = assetLink
    }
    
    public var deepLink: URL? {
        guard let path = assetLink.url.asURL?.path().trimmingPrefix("/") else { return nil }
        
        return switch assetLink.linkType {
        case .telegram: URL(string: "tg://resolve?domain=\(path)")
        case .x: URL(string: "twitter://user?screen_name=\(path)")
        case .youTube: URL(string: "youtube://www.youtube.com/\(path)")
        case .discord: URL(string: "https://discord.gg/\(path)")
        case .gitHub: URL(string: "https://github.com/\(path)")
        case .none, .reddit, .facebook, .website, .coingecko, .openSea, .instagram, .magicEden, .coinMarketCap, .tikTok:
            nil
        }
    }
}

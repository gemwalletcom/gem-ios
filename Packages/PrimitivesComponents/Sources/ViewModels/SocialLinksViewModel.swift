// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import Primitives

public struct SocialLinksViewModel {
    public let assetLinks: [AssetLink]
    
    public init(assetLinks: [AssetLink]) {
        self.assetLinks = assetLinks
    }

    var links: [InsightLink] {
        assetLinks
            .sorted()
            .compactMap { AssetLinkViewModel(assetLink: $0).insightLink }
    }
}

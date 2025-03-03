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
            .compactMap { AssetLinkViewModel($0).insightLink }
    }
}

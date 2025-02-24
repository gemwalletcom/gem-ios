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
            .compactMap { $0.asInsightLink }
    }
}

extension AssetLink {
    var asInsightLink: InsightLink? {
        guard let link = linkType, let url = URL(string: url) else {
            return .none
        }
        let linkModel = LinkTypeViewModel(link: link)
        return InsightLink(
            title: linkModel.name,
            subtitle: url.cleanHost(),
            url: url,
            image: linkModel.image
        )
    }
}

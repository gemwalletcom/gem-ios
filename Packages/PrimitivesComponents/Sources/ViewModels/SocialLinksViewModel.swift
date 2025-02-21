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
            .compactMap {
                if let link = $0.linkType {
                    return LinkTypeViewModel(link: link)
                }
                return .none
            }
            .sorted(by: { $0.order > $1.order })
            .compactMap {
                guard let url = $0.url else {
                    return .none
                }
                return InsightLink(
                    title: $0.name,
                    subtitle: $0.host,
                    url: url,
                    image: $0.image
                )
            }
    }
}

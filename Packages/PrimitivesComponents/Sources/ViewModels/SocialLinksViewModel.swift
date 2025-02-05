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
            .sorted(by: { $0.socialUrl?.order ?? 0 > $1.socialUrl?.order ?? 0 })
            .compactMap {
                guard let type = $0.socialUrl,
                      let url = URL(string: $0.url)
                else {
                    return .none
                }
                return InsightLink(
                    title: type.name,
                    subtitle: $0.host(for: type),
                    url: url,
                    image: type.image
                )
            }
    }
}

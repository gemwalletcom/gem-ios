// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Gemstone
import Localization

public struct SocialLinksViewModel {
    public let links: [AssetLink]
    public let linksSectionText: String
    
    public init(
        links: [AssetLink],
        linksSectionText: String
    ) {
        self.links = links
        self.linksSectionText = linksSectionText
    }

    var insightLinks: [InsightLink] {
        return links.map {
            if let type = communityLink(for: $0.name),
               let url = URL(string: $0.url) {
                return CommunityLink(type: type, url: url)
            }
            return .none
        }
        .compactMap { $0 }
        .sorted()
        .map {
            InsightLink(
                title: $0.type.name,
                subtitle: $0.host,
                url: $0.url,
                image: $0.type.image
            )
        }
    }
    
    private func communityLink(for value: String) -> SocialUrl? {
        switch value.lowercased() {
        case "x": .x
        case "x (formerly twitter)": .x
        case "discord": .discord
        case "reddit": .reddit
        case "telegram": .telegram
        case "youtube": .youTube
        case "facebook": .facebook
        case "website": .website
        case "coingecko": .coingecko
        case "github": .gitHub
        default: .none
        }
    }
}

public struct SocialLinksView: View {
    public let model: SocialLinksViewModel

    public init(model: SocialLinksViewModel) {
        self.model = model
    }

    public var body: some View {
        Section(model.linksSectionText) {
            ForEach(model.insightLinks) {
                NavigationOpenLink(
                    url: $0.url,
                    with: ListItemView(title: $0.title, subtitle: $0.subtitle, image: $0.image)
                )
            }
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Components

public struct SocialLinksView: View {
    public let model: SocialLinksViewModel

    public init(model: SocialLinksViewModel) {
        self.model = model
    }

    public var body: some View {
        ForEach(model.links) { link in
            SafariNavigationLink(url: link.url) {
                ListItemView(
                    title: link.title,
                    subtitle: link.subtitle,
                    imageStyle: .settings(assetImage: link.image)
                )
            }
        }
    }
}

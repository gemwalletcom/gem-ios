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
            let view = ListItemView(
                title: link.title,
                subtitle: link.subtitle,
                imageStyle: .settings(assetImage: link.image)
            )
            if let deepLink = link.deepLink, UIApplication.shared.canOpenURL(deepLink) {
                NavigationCustomLink(with: view) {
                    UIApplication.shared.open(deepLink)
                }
            } else {
                SafariNavigationLink(url: link.url) {
                    view
                }
            }
        }
    }
}

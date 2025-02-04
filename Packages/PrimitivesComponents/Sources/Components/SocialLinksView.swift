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
        ForEach(model.insightLinks) {
            NavigationOpenLink(
                url: $0.url,
                with: ListItemView(title: $0.title, subtitle: $0.subtitle, image: $0.image)
            )
        }
    }
}

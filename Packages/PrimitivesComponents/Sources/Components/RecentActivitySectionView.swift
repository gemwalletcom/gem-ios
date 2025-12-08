// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Localization

public struct RecentActivitySectionView<Content: View>: View {
    private let models: [AssetViewModel]
    private let headerPadding: CGFloat
    private let content: (AssetViewModel) -> Content

    public init(
        models: [AssetViewModel],
        headerPadding: CGFloat = Spacing.space12,
        @ViewBuilder content: @escaping (AssetViewModel) -> Content
    ) {
        self.models = models
        self.headerPadding = headerPadding
        self.content = content
    }

    public var body: some View {
        Section {} header: {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(Localized.RecentActivity.title)
                    .padding(.leading, headerPadding)
                AssetsCollectionView(models: models, content: content)
            }
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets())
    }
}

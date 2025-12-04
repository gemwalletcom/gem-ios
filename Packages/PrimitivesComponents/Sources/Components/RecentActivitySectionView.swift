// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Localization

public struct RecentActivitySectionView<Content: View>: View {
    private let models: [AssetViewModel]
    private let content: (AssetViewModel) -> Content

    public init(
        models: [AssetViewModel],
        @ViewBuilder content: @escaping (AssetViewModel) -> Content
    ) {
        self.models = models
        self.content = content
    }

    public var body: some View {
        Section {} header: {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(Localized.RecentActivity.title)
                    .padding(.top, .small)
                    .padding(.leading, .medium + .tiny)
                AssetsCollectionView(models: models, content: content)
            }
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets())
    }
}

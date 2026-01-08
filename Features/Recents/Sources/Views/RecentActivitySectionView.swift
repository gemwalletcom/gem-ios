// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Style
import Localization

public struct RecentActivitySectionView<Content: View>: View {
    private let models: [AssetViewModel]
    private let headerPadding: CGFloat
    private let onSelectRecents: VoidAction
    private let content: (AssetViewModel) -> Content

    public init(
        models: [AssetViewModel],
        headerPadding: CGFloat = Spacing.space12,
        onSelectRecents: VoidAction = nil,
        @ViewBuilder content: @escaping (AssetViewModel) -> Content
    ) {
        self.models = models
        self.headerPadding = headerPadding
        self.onSelectRecents = onSelectRecents
        self.content = content
    }

    public var body: some View {
        Section {} header: {
            VStack(alignment: .leading, spacing: Spacing.space12) {
                headerView
                    .padding(.leading, headerPadding)
                AssetsCollectionView(models: models, content: content)
            }
            .padding(.top, Spacing.small)
            .padding(.bottom, Spacing.tiny)
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets())
    }

    @ViewBuilder
    private var headerView: some View {
        Button {
            onSelectRecents?()
        } label: {
            HStack {
                Text(Localized.RecentActivity.title)
                if onSelectRecents != nil {
                    Images.System.chevronRight
                }
            }
        }
        .buttonStyle(.plain)
    }
}
